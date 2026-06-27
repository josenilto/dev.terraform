locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })

  # Storage Account: máx 24 chars, somente letras minúsculas e números
  env_short    = substr(var.environment, 0, 3)
  project_part = substr(replace(var.project_name, "-", ""), 0, 8)
  storage_name = lower("${local.project_part}${local.env_short}${var.storage_name_suffix}")
}

resource "azurerm_storage_account" "main" {
  name                     = local.storage_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.replication_type
  min_tls_version          = "TLS1_2"

  blob_properties {
    versioning_enabled = false
  }

  tags = local.common_tags
}

resource "azurerm_storage_container" "main" {
  count = var.container_name != "" ? 1 : 0

  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = var.container_access_type
}
