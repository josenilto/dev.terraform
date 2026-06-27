# ── Backend Remoto S3 (recomendado para trabalho em equipe) ───────────────────
#
# Por padrão, o Terraform usa backend local (arquivo terraform.tfstate no disco).
# Para trabalho em equipe ou pipelines CI/CD, use backend remoto com lock.
#
# Pré-requisitos (execute UMA VEZ por conta AWS):
#
#   1. Criar bucket de state:
#      aws s3api create-bucket \
#        --bucket meu-projeto-tfstate \
#        --region us-east-1
#
#      aws s3api put-bucket-versioning \
#        --bucket meu-projeto-tfstate \
#        --versioning-configuration Status=Enabled
#
#   2. Criar tabela DynamoDB para lock:
#      aws dynamodb create-table \
#        --table-name terraform-state-lock \
#        --attribute-definitions AttributeName=LockID,AttributeType=S \
#        --key-schema AttributeName=LockID,KeyType=HASH \
#        --billing-mode PAY_PER_REQUEST \
#        --region us-east-1
#
#   3. Descomente o bloco abaixo, ajuste os valores e rode:
#      terraform init -reconfigure
#
# terraform {
#   backend "s3" {
#     bucket         = "meu-projeto-tfstate"
#     key            = "dev/aws/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }
