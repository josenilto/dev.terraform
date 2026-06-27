# IAM Role para Fargate Profile
resource "aws_iam_role" "fargate" {
  name = "${var.project_name}-fargate-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks-fargate-pods.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "fargate_pod_execution" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate.name
}

# ─────────────────────────────────────────────────────
# Fargate Profiles — um por namespace
# FinOps: Fargate elimina custo de nós ociosos para
#         workloads intermitentes ou de baixo volume
# ─────────────────────────────────────────────────────
resource "aws_eks_fargate_profile" "namespaces" {
  for_each = toset(var.fargate_namespaces)

  cluster_name           = aws_eks_cluster.main.name
  fargate_profile_name   = "${var.project_name}-fargate-${each.key}"
  pod_execution_role_arn = aws_iam_role.fargate.arn
  subnet_ids             = aws_subnet.private[*].id

  selector {
    namespace = each.key
  }

  tags = {
    Name      = "${var.project_name}-fargate-${each.key}"
    Namespace = each.key
    Billing   = "per-pod"
  }

  depends_on = [aws_iam_role_policy_attachment.fargate_pod_execution]
}
