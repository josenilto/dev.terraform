variable "resource_group_name" {
  description = "Nome do Resource Group que conterá os recursos do ACR privado"
  type        = string
  default     = "rg-acr-privado"
}

variable "location" {
  description = "Região do Azure onde os recursos serão provisionados"
  type        = string
  default     = "East US"
}

# ── Nomenclatura ──────────────────────────────────────────────────────────────

variable "project_abbrev" {
  description = "Abreviação do projeto (até 10 chars, apenas letras minúsculas e números) — compõe o nome do ACR"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{1,10}$", var.project_abbrev))
    error_message = "project_abbrev deve conter apenas letras minúsculas e números, até 10 caracteres."
  }
}

variable "environment" {
  description = "Ambiente de implantação: development | staging | production"
  type        = string
  default     = "development"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "environment deve ser development, staging ou production."
  }
}

# ── ACR ──────────────────────────────────────────────────────────────────────

variable "acr_sku" {
  description = "SKU do ACR — deve ser Premium para suportar Private Endpoint"
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Premium"], var.acr_sku)
    error_message = "ACR privado requer SKU Premium."
  }
}

variable "admin_enabled" {
  description = "Habilita o usuário administrador para autenticação via docker login"
  type        = bool
  default     = false
}

variable "quarantine_policy_enabled" {
  description = "Habilita quarentena de imagens antes de disponibilizá-las (apenas Premium)"
  type        = bool
  default     = false
}

variable "retention_days" {
  description = "Dias para retenção de imagens sem tag (apenas Premium)"
  type        = number
  default     = 7

  validation {
    condition     = var.retention_days >= 0 && var.retention_days <= 365
    error_message = "O período de retenção deve ser entre 0 e 365 dias."
  }
}

variable "trust_policy_enabled" {
  description = "Habilita confiança no conteúdo (assinatura de imagens) — apenas Premium"
  type        = bool
  default     = false
}

# ── Rede ─────────────────────────────────────────────────────────────────────

variable "vnet_name" {
  description = "Nome da Virtual Network"
  type        = string
  default     = "vnet-acr-privado"
}

variable "vnet_address_space" {
  description = "Espaço de endereçamento da VNet (CIDR)"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Nome da subnet destinada ao Private Endpoint"
  type        = string
  default     = "snet-private-endpoint"
}

variable "subnet_address_prefixes" {
  description = "Prefixo de endereço da subnet do Private Endpoint (CIDR)"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

# ── FinOps ────────────────────────────────────────────────────────────────────

variable "estimated_storage_gb" {
  description = "Estimativa de armazenamento de imagens em GB (Premium inclui 500 GB)"
  type        = number
  default     = 50
}

variable "estimated_build_minutes_per_month" {
  description = "Estimativa de minutos de build no ACR Tasks por mês"
  type        = number
  default     = 0
}

variable "estimated_monthly_dns_queries_millions" {
  description = "Estimativa de consultas à zona DNS privada por mês (em milhões)"
  type        = number
  default     = 1
}

variable "estimated_egress_gb_per_month" {
  description = "Estimativa de transferência de dados para fora da região por mês (GB)"
  type        = number
  default     = 10
}

# ── Tags ─────────────────────────────────────────────────────────────────────

variable "tags" {
  description = "Mapa de tags aplicadas a todos os recursos"
  type        = map(string)
  default     = {}
}
