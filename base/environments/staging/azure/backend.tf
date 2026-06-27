# ── Backend Remoto Azure ──────────────────────────────────────────────────────
# O state de staging DEVE usar backend remoto para CI/CD e trabalho em equipe.
#
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "tfstate-rg"
#     storage_account_name = "meuprojetotfstate"
#     container_name       = "tfstate"
#     key                  = "staging/azure/terraform.tfstate"   # path único
#   }
# }
