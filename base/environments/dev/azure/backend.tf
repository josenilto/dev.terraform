# ── Backend Remoto Azure (recomendado para trabalho em equipe) ────────────────
#
# Por padrão, o Terraform usa backend local (arquivo terraform.tfstate no disco).
# Para trabalho em equipe ou pipelines CI/CD, use backend remoto com lock.
#
# Pré-requisitos (execute UMA VEZ):
#
#   1. Criar Resource Group para o state:
#      az group create --name tfstate-rg --location eastus
#
#   2. Criar Storage Account (nome globalmente único):
#      az storage account create \
#        --name meuprojetotfstate \
#        --resource-group tfstate-rg \
#        --location eastus \
#        --sku Standard_LRS
#
#   3. Criar container de blobs:
#      az storage container create \
#        --name tfstate \
#        --account-name meuprojetotfstate
#
#   4. Descomente o bloco abaixo, ajuste os valores e rode:
#      terraform init -reconfigure
#
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "tfstate-rg"
#     storage_account_name = "meuprojetotfstate"
#     container_name       = "tfstate"
#     key                  = "dev/azure/terraform.tfstate"
#   }
# }
