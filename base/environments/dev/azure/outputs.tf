output "resource_group_name" {
  description = "Nome do Resource Group criado"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
  description = "ID da Virtual Network"
  value       = module.rede.vnet_id
}

output "subnet_ids" {
  description = "Mapa de IDs das subnets"
  value       = module.rede.subnet_ids
}

output "vm_id" {
  description = "ID da Virtual Machine"
  value       = module.compute.vm_id
}

output "vm_private_ip" {
  description = "IP privado da VM"
  value       = module.compute.private_ip
}

output "vm_public_ip" {
  description = "IP público da VM (null se enable_public_ip = false)"
  value       = module.compute.public_ip
}

output "storage_account_name" {
  description = "Nome da Storage Account"
  value       = module.storage.storage_account_name
}

output "primary_blob_endpoint" {
  description = "Endpoint de Blob Storage"
  value       = module.storage.primary_blob_endpoint
}
