# ── Backend Remoto S3 — OBRIGATÓRIO em prod ───────────────────────────────────
# Em produção, NUNCA use backend local. O state remoto garante:
#   - Colaboração segura em equipe
#   - Lock para evitar conflitos de apply simultâneo
#   - Histórico de mudanças via versionamento do bucket
#
# terraform {
#   backend "s3" {
#     bucket         = "meu-projeto-tfstate"
#     key            = "prod/aws/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }
