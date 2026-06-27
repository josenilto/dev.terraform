output "resource_group_name" {
  description = "Nome do Resource Group criado"
  value       = azurerm_resource_group.rg.name
}

output "acr_id" {
  description = "ID do recurso do Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_name" {
  description = "Nome gerado do Azure Container Registry (padrão: acr{projeto}{ambiente}{sufixo})"
  value       = azurerm_container_registry.acr.name
}

output "acr_name_pattern" {
  description = "Padrão de nomenclatura aplicado ao ACR"
  value       = "acr${var.project_abbrev}${local.env_short}<6-chars-random>"
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

output "vnet_id" {
  description = "ID da Virtual Network criada"
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_id" {
  description = "ID da subnet do Private Endpoint"
  value       = azurerm_subnet.private_endpoint_subnet.id
}

output "private_endpoint_id" {
  description = "ID do Private Endpoint do ACR"
  value       = azurerm_private_endpoint.acr_pe.id
}

output "private_endpoint_ip" {
  description = "IP privado atribuído ao Private Endpoint do ACR"
  value       = azurerm_private_endpoint.acr_pe.private_service_connection[0].private_ip_address
}

output "private_dns_zone_id" {
  description = "ID da zona DNS privada criada para o ACR"
  value       = azurerm_private_dns_zone.acr_dns.id
}
