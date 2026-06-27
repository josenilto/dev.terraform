variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente: dev | staging | prod"
  type        = string
}

variable "location" {
  description = "Região Azure"
  type        = string
}

variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "account_tier" {
  description = "Tier da Storage Account: Standard | Premium"
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  description = "Tipo de replicação: LRS (local) | ZRS (zona) | GRS (geográfica) | RAGRS"
  type        = string
  default     = "LRS"
}

variable "container_name" {
  description = "Nome do container de blobs a criar (deixe vazio para não criar)"
  type        = string
  default     = "dados"
}

variable "container_access_type" {
  description = "Nível de acesso público do container: private | blob | container"
  type        = string
  default     = "private"
}

variable "storage_name_suffix" {
  description = "Sufixo numérico para garantir unicidade global do nome da Storage Account"
  type        = string
}

variable "tags" {
  description = "Tags extras"
  type        = map(string)
  default     = {}
}
