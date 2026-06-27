# ── Backend Remoto Azure — OBRIGATÓRIO em prod ────────────────────────────────
# Em produção, o state remoto com lock é inegociável.
#
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "tfstate-rg"
#     storage_account_name = "meuprojetotfstate"
#     container_name       = "tfstate"
#     key                  = "prod/azure/terraform.tfstate"
#   }
# }
