output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "vnet_id" {
  value = module.rede.vnet_id
}

output "subnet_ids" {
  value = module.rede.subnet_ids
}

output "vm_id" {
  value = module.compute.vm_id
}

output "vm_private_ip" {
  value = module.compute.private_ip
}

output "vm_public_ip" {
  value = module.compute.public_ip
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "primary_blob_endpoint" {
  value = module.storage.primary_blob_endpoint
}
