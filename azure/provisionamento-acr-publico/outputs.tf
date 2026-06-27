output "resource_group_name" {
  description = "Nome do Resource Group criado"
  value       = azurerm_resource_group.rg.name
}

output "acr_id" {
  description = "ID do recurso do Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_name" {
  description = "Nome único gerado para o Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "URL do servidor de login — use em docker login e image tags"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "Usuário administrador do ACR"
  value       = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  description = "Senha do administrador do ACR"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

# ──────────────────── FinOps ────────────────────

output "finops_budget_name" {
  description = "Nome do budget de custo mensal criado no Azure Cost Management"
  value       = azurerm_consumption_budget_resource_group.acr_budget.name
}

output "finops_budget_amount_usd" {
  description = "Limite mensal de custo configurado em USD"
  value       = var.budget_amount_monthly
}

output "finops_estimated_monthly_cost_usd" {
  description = "Estimativa de custo mensal base do ACR pelo SKU selecionado (sem storage/operações)"
  value       = local.sku_cost.registry
}
