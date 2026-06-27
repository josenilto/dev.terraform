# ── Backend Remoto S3 ─────────────────────────────────────────────────────────
# O state de staging DEVE usar backend remoto para permitir deploys via CI/CD.
# Veja README.md para pré-requisitos de criação do bucket e tabela DynamoDB.
#
# terraform {
#   backend "s3" {
#     bucket         = "meu-projeto-tfstate"
#     key            = "staging/aws/terraform.tfstate"   # path único por ambiente
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }
