variable "region" {
  description = "Região AWS onde o bucket S3 será criado"
  type        = string
  default     = "us-east-1"
}

# ── Nomenclatura ──────────────────────────────────────────────────────────────

variable "project_abbrev" {
  description = "Abreviação do projeto (até 12 chars, apenas letras minúsculas e números) — compõe o nome do bucket"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{1,12}$", var.project_abbrev))
    error_message = "project_abbrev deve conter apenas letras minúsculas e números, até 12 caracteres."
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

# ── S3 ────────────────────────────────────────────────────────────────────────

variable "versioning_enabled" {
  description = "Habilita versionamento de objetos no bucket"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Permite destruir o bucket mesmo com objetos — use false em produção"
  type        = bool
  default     = false
}

variable "cors_allowed_origins" {
  description = "Lista de origens permitidas para CORS (ex: [\"https://meusite.com\"])"
  type        = list(string)
  default     = ["*"]
}

# ── FinOps ────────────────────────────────────────────────────────────────────

variable "estimated_storage_gb" {
  description = "Estimativa de armazenamento em GB (S3 Standard: $0.023/GB/mês)"
  type        = number
  default     = 10
}

variable "estimated_put_requests_thousands" {
  description = "Estimativa de requisições PUT/POST/COPY/LIST por mês (em milhares)"
  type        = number
  default     = 10
}

variable "estimated_get_requests_thousands" {
  description = "Estimativa de requisições GET/SELECT por mês (em milhares)"
  type        = number
  default     = 100
}

variable "estimated_egress_gb_per_month" {
  description = "Estimativa de transferência de dados para a internet por mês (GB)"
  type        = number
  default     = 10
}

variable "budget_amount_monthly" {
  description = "Limite mensal de custo em USD para alerta de orçamento"
  type        = number
  default     = 20
}

variable "budget_contact_emails" {
  description = "Lista de e-mails que recebem alertas de orçamento"
  type        = list(string)
  default     = []
}

# ── Tags ─────────────────────────────────────────────────────────────────────

variable "tags" {
  description = "Mapa de tags aplicadas a todos os recursos"
  type        = map(string)
  default     = {}
}
