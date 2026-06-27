variable "region" {
  description = "Região AWS onde os recursos RDS serão criados"
  type        = string
  default     = "us-east-1"
}

# ── Nomenclatura ──────────────────────────────────────────────────────────────

variable "project_abbrev" {
  description = "Abreviação do projeto (até 12 chars, apenas letras minúsculas e números) — compõe o identifier do RDS"
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

# ── Rede ──────────────────────────────────────────────────────────────────────

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_a_cidr" {
  description = "CIDR block da Subnet A (Availability Zone 1 — RDS Master)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_b_cidr" {
  description = "CIDR block da Subnet B (Availability Zone 2 — RDS Read Replica)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "az_a" {
  description = "Availability Zone para Subnet A (RDS Master)"
  type        = string
  default     = "us-east-1a"
}

variable "az_b" {
  description = "Availability Zone para Subnet B (RDS Read Replica)"
  type        = string
  default     = "us-east-1b"
}

variable "allowed_cidr_blocks" {
  description = "Lista de CIDRs autorizados a conectar na porta PostgreSQL (5432). Use [\"0.0.0.0/0\"] para acesso público total"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ── RDS ───────────────────────────────────────────────────────────────────────

variable "db_instance_class" {
  description = "Classe da instância RDS (ex: db.t3.micro, db.t3.small, db.t3.medium)"
  type        = string
  default     = "db.t3.micro"
}

variable "db_engine_version" {
  description = "Versão do PostgreSQL (ex: 15.4, 16.1)"
  type        = string
  default     = "16.1"
}

variable "db_allocated_storage" {
  description = "Armazenamento inicial alocado em GB (GP2)"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Armazenamento máximo para autoscaling em GB (0 = desabilitado)"
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Nome do banco de dados criado no momento do provisionamento"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Nome do usuário master do RDS"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Senha do usuário master do RDS (mínimo 8 caracteres)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "db_password deve ter no mínimo 8 caracteres."
  }
}

variable "db_port" {
  description = "Porta de conexão do PostgreSQL"
  type        = number
  default     = 5432
}

variable "db_backup_retention_period" {
  description = "Retenção de backups automáticos em dias (mínimo 1 para habilitar Read Replica)"
  type        = number
  default     = 7
}

variable "db_deletion_protection" {
  description = "Proteção contra deleção acidental — recomendado true em produção"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Pula snapshot final ao destruir o RDS — use false em produção"
  type        = bool
  default     = true
}

variable "db_apply_immediately" {
  description = "Aplica mudanças imediatamente sem esperar a maintenance window"
  type        = bool
  default     = false
}

variable "db_multi_az" {
  description = "Habilita Multi-AZ standby no master (diferente de Read Replica)"
  type        = bool
  default     = false
}

variable "db_storage_encrypted" {
  description = "Habilita criptografia do armazenamento com AWS KMS"
  type        = bool
  default     = true
}

# ── FinOps ────────────────────────────────────────────────────────────────────

variable "estimated_instance_hourly_price_usd" {
  description = "Preço por hora de UMA instância RDS (ex: db.t3.micro = $0.017). Aplicado ao master e à replica separadamente"
  type        = number
  default     = 0.017
}

variable "estimated_storage_gb" {
  description = "Armazenamento GP2 alocado em GB — base de cálculo de custo de storage"
  type        = number
  default     = 20
}

variable "estimated_backup_storage_gb" {
  description = "GB de backup além do free tier (igual ao storage alocado). Cobrança: $0.095/GB/mês"
  type        = number
  default     = 20
}

variable "estimated_egress_gb_per_month" {
  description = "Estimativa de transferência de dados para a internet por mês (GB) — $0.09/GB"
  type        = number
  default     = 10
}

variable "budget_amount_monthly" {
  description = "Limite mensal de custo em USD para alertas de orçamento"
  type        = number
  default     = 80
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
