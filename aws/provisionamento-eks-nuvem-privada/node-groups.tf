# IAM Role compartilhado pelos nós EC2
resource "aws_iam_role" "eks_nodes" {
  name = "${var.project_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# Security Group dos nós
resource "aws_security_group" "eks_nodes" {
  name        = "${var.project_name}-eks-nodes-sg"
  description = "Security Group dos nós EC2 do EKS"
  vpc_id      = aws_vpc.eks.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
    description     = "Control Plane para nós"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-eks-nodes-sg" }
}

# ─────────────────────────────────────────────────────
# Node Group — EC2 Managed (gerenciado pelo EKS)
# FinOps: Spot instances com on-demand como fallback
# ─────────────────────────────────────────────────────
resource "aws_eks_node_group" "managed" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-managed"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = aws_subnet.private[*].id

  capacity_type  = "SPOT"
  instance_types = var.managed_node_instance_types
  disk_size      = 20

  scaling_config {
    desired_size = var.managed_node_desired
    min_size     = var.managed_node_min
    max_size     = var.managed_node_max
  }

  update_config {
    max_unavailable_percentage = 25
  }

  labels = {
    role         = "managed"
    capacity     = "spot"
    "cost-class" = "optimized"
  }

  taint {
    key    = "dedicated"
    value  = "managed"
    effect = "NO_SCHEDULE"
  }

  tags = {
    Name                                        = "${var.project_name}-node-managed"
    "k8s.io/cluster-autoscaler/enabled"        = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    CapacityType                                = "SPOT"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only,
  ]
}

# ─────────────────────────────────────────────────────
# Node Group — EC2 Self-managed (controle personalizado)
# FinOps: On-demand para cargas críticas e stateful
# ─────────────────────────────────────────────────────
resource "aws_launch_template" "self_managed" {
  name_prefix            = "${var.project_name}-self-managed-"
  image_id               = data.aws_ssm_parameter.eks_ami.value
  instance_type          = var.self_managed_node_instance_types[0]
  vpc_security_group_ids = [aws_security_group.eks_nodes.id]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 50
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 125
      encrypted             = true
      kms_key_id            = aws_kms_key.eks.arn
      delete_on_termination = true
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.eks_nodes.arn
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  monitoring { enabled = true }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    /etc/eks/bootstrap.sh ${var.cluster_name} \
      --b64-cluster-ca ${aws_eks_cluster.main.certificate_authority[0].data} \
      --apiserver-endpoint ${aws_eks_cluster.main.endpoint} \
      --kubelet-extra-args '--node-labels=role=self-managed,cost-class=on-demand'
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-node-self-managed"
      CapacityType = "ON_DEMAND"
    }
  }

  lifecycle { create_before_destroy = true }
}

data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/${var.cluster_version}/amazon-linux-2/recommended/image_id"
}

resource "aws_iam_instance_profile" "eks_nodes" {
  name = "${var.project_name}-eks-node-profile"
  role = aws_iam_role.eks_nodes.name
}

resource "aws_autoscaling_group" "self_managed" {
  name                = "${var.project_name}-self-managed-asg"
  desired_capacity    = var.self_managed_node_desired
  min_size            = var.self_managed_node_min
  max_size            = var.self_managed_node_max
  vpc_zone_identifier = aws_subnet.private[*].id

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.self_managed.id
        version            = "$Latest"
      }

      # FinOps: mix de tipos de instância para reduzir custo
      dynamic "override" {
        for_each = var.self_managed_node_instance_types
        content {
          instance_type = override.value
        }
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "price-capacity-optimized"
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-node-self-managed"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 75
    }
  }

  lifecycle { create_before_destroy = true }
}

# ─────────────────────────────────────────────────────
# Cluster Autoscaler — IAM Role (IRSA)
# ─────────────────────────────────────────────────────
resource "aws_iam_role" "cluster_autoscaler" {
  name = "${var.project_name}-cluster-autoscaler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name        = "${var.project_name}-cluster-autoscaler-policy"
  description = "Permite ao Cluster Autoscaler escalar os ASGs do EKS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = aws_iam_role.cluster_autoscaler.name
}
