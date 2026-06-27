output "vm_id" {
  description = "ID da Virtual Machine"
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm_name" {
  description = "Nome da Virtual Machine"
  value       = azurerm_linux_virtual_machine.main.name
}

output "private_ip" {
  description = "IP privado atribuído à NIC da VM"
  value       = azurerm_network_interface.main.private_ip_address
}

output "public_ip" {
  description = "IP público da VM (null quando enable_public_ip = false)"
  value       = var.enable_public_ip ? azurerm_public_ip.main[0].ip_address : null
}
