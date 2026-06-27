# ─────────────────────────────────────────────────────
# ECR — Repositórios privados de imagens
# VPC separada conforme arquitetura de referência
# FinOps: lifecycle policy reduz custo de armazenamento
# ─────────────────────────────────────────────────────
resource "aws_ecr_repository" "apps" {
  for_each = toset(var.ecr_repositories)

  name                 = "${var.project_name}/${each.key}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr.arn
  }

  tags = {
    Name       = "${var.project_name}-ecr-${each.key}"
    Repository = each.key
  }
}

# FinOps: expirar imagens antigas para reduzir custo de storage ECR
resource "aws_ecr_lifecycle_policy" "apps" {
  for_each   = aws_ecr_repository.apps
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Manter apenas as últimas ${var.ecr_image_retention_count} imagens por repositório"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.ecr_image_retention_count
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Expirar imagens não-tagueadas após 7 dias"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = { type = "expire" }
      }
    ]
  })
}

# KMS para ECR
resource "aws_kms_key" "ecr" {
  description             = "KMS key para criptografia de imagens ECR - ${var.project_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = { Name = "${var.project_name}-ecr-kms" }
}

resource "aws_kms_alias" "ecr" {
  name          = "alias/${var.project_name}-ecr"
  target_key_id = aws_kms_key.ecr.key_id
}

# VPC Endpoint para ECR — acesso sem tráfego pela internet (reduz NAT Gateway cost)
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.eks.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = { Name = "${var.project_name}-vpce-ecr-api" }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.eks.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = { Name = "${var.project_name}-vpce-ecr-dkr" }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.eks.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = { Name = "${var.project_name}-vpce-s3" }
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.project_name}-vpce-sg"
  description = "Security Group dos VPC Endpoints (ECR, S3)"
  vpc_id      = aws_vpc.eks.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  tags = { Name = "${var.project_name}-vpce-sg" }
}

# ECR Replication — opcional, descomentado apenas se multi-region for necessário
# resource "aws_ecr_replication_configuration" "cross_region" {
#   replication_configuration {
#     rule {
#       destination {
#         region      = "us-west-2"
#         registry_id = data.aws_caller_identity.current.account_id
#       }
#     }
#   }
# }
