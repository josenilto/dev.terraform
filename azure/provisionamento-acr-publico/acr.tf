resource "random_string" "acr_suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

locals {
  # Padrão: acr + {project_prefix} + {6 chars aleatórios} → ex: acrdevopsab3f2c
  acr_name = "acr${var.project_prefix}${random_string.acr_suffix.result}"
}

resource "azurerm_container_registry" "acr" {
  name                          = local.acr_name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  sku                           = var.acr_sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = true

  tags = var.tags
}
