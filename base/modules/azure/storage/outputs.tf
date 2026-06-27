output "storage_account_id" {
  description = "ID da Storage Account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "Nome da Storage Account (globalmente único)"
  value       = azurerm_storage_account.main.name
}

output "primary_blob_endpoint" {
  description = "Endpoint primário do serviço de Blob Storage"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "primary_access_key" {
  description = "Chave de acesso primária — marcar como sensitive para não exibir em logs"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}
