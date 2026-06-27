output "vnet_id" {
  description = "ID da Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Nome da Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_ids" {
  description = "Mapa de IDs das subnets (chave = nome lógico definido em var.subnets)"
  value       = { for k, v in azurerm_subnet.main : k => v.id }
}

output "nsg_id" {
  description = "ID do Network Security Group"
  value       = azurerm_network_security_group.main.id
}
