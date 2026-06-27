variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente: dev | staging | prod"
  type        = string
}

variable "bucket_suffix" {
  description = "Sufixo único para o nome do bucket — gere com random_string para evitar conflitos globais"
  type        = string
}

variable "versioning_enabled" {
  description = "Habilita versionamento de objetos — recomendado em staging e prod"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Permite destruir o bucket mesmo com objetos — use true apenas em dev"
  type        = bool
  default     = false
}

variable "lifecycle_noncurrent_expiration_days" {
  description = "Dias para expirar versões não-correntes de objetos (0 = desabilitado)"
  type        = number
  default     = 0
}

variable "server_side_encryption" {
  description = "Habilita criptografia SSE-S3 (AES256) em todos os objetos"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags extras aplicadas ao bucket"
  type        = map(string)
  default     = {}
}
