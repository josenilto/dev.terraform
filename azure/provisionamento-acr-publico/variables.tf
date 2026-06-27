variable "resource_group_name" {
  description = "Nome do Resource Group que conterá os recursos do ACR"
  type        = string
  default     = "rg-acr-publico"
}

variable "location" {
  description = "Região do Azure onde os recursos serão provisionados"
  type        = string
  default     = "East US"
}

variable "project_prefix" {
  description = "Prefixo do projeto — compõe o nome único do ACR (ex: 'devops' gera 'acrdevopsXXXXXX')"
  type        = string
  default     = "devops"

  validation {
    condition     = can(regex("^[a-z0-9]{3,20}$", var.project_prefix))
    error_message = "O prefixo deve conter apenas letras minúsculas e números, entre 3 e 20 caracteres."
  }
}

variable "acr_sku" {
  description = "SKU do ACR — Basic (~$5/mês), Standard (~$20/mês), Premium (~$50/mês)"
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "O SKU deve ser Basic, Standard ou Premium."
  }
}

variable "admin_enabled" {
  description = "Habilita o usuário administrador para autenticação via docker login"
  type        = bool
  default     = true
}

# ──────────────────── FinOps ────────────────────

variable "budget_amount_monthly" {
  description = "Limite mensal de custo em USD para alerta de orçamento do ACR"
  type        = number
  default     = 30
}

variable "budget_contact_emails" {
  description = "Lista de e-mails que recebem alertas de orçamento"
  type        = list(string)
  default     = []
}

variable "budget_start_date" {
  description = "Data de início do ciclo de orçamento (primeiro dia do mês, formato: YYYY-MM-01T00:00:00Z)"
  type        = string
  default     = "2026-06-01T00:00:00Z"
}

# ────────────────────────────────────────────────

variable "tags" {
  description = "Mapa de tags aplicadas a todos os recursos"
  type        = map(string)
  default     = {}
}
