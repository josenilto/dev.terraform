resource "azurerm_container_registry" "acr" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.acr_sku
  admin_enabled       = var.admin_enabled

  # Bloqueia todo acesso público — acesso apenas via Private Endpoint
  public_network_access_enabled = false

  # Requer SKU Premium para habilitar políticas de quarentena de imagens
  quarantine_policy_enabled = var.quarantine_policy_enabled

  # Retenção de imagens sem tag (apenas Premium)
  retention_policy {
    days    = var.retention_days
    enabled = true
  }

  # Confiança no conteúdo (assinatura de imagens)
  trust_policy {
    enabled = var.trust_policy_enabled
  }

  tags = var.tags
}
