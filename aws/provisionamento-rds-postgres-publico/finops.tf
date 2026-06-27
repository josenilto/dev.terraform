# ── FinOps — Estimativa de Custo Mensal (AWS us-east-1, USD) ─────────────────
#
#  Preços de referência (verificar em https://aws.amazon.com/rds/postgresql/pricing):
#    RDS PostgreSQL — On-Demand
#      db.t3.micro    : $0.017/hora  (~$12.41/mês)
#      db.t3.small    : $0.034/hora  (~$24.82/mês)
#      db.t3.medium   : $0.068/hora  (~$49.64/mês)
#    Storage GP2      : $0.115/GB/mês
#    Backup Storage   : $0.095/GB/mês (além do free tier = tamanho do DB)
#    Egress (internet): $0.09/GB      (primeiros 10 TB/mês)
#    Transfer IN      : $0.00         (entrada de dados é gratuita)
#
#  Arquitetura: 1 Master (R/W) + 1 Read Replica (R/O) = 2 instâncias
# ─────────────────────────────────────────────────────────────────────────────

locals {
  hours_per_month = 720

  # ── Preços unitários ──────────────────────────────────────────────────────
  price_instance_per_hour  = var.estimated_instance_hourly_price_usd
  price_storage_gp2_per_gb = 0.115
  price_backup_per_gb      = 0.095
  price_egress_per_gb      = 0.09

  # ── Custos mensais por componente ─────────────────────────────────────────
  cost_master_instance  = local.price_instance_per_hour * local.hours_per_month
  cost_replica_instance = local.price_instance_per_hour * local.hours_per_month

  cost_master_storage  = var.estimated_storage_gb * local.price_storage_gp2_per_gb
  cost_replica_storage = var.estimated_storage_gb * local.price_storage_gp2_per_gb

  cost_backup = var.estimated_backup_storage_gb * local.price_backup_per_gb
  cost_egress = var.estimated_egress_gb_per_month * local.price_egress_per_gb

  # ── Totais ────────────────────────────────────────────────────────────────
  total_monthly_usd = (
    local.cost_master_instance +
    local.cost_replica_instance +
    local.cost_master_storage +
    local.cost_replica_storage +
    local.cost_backup +
    local.cost_egress
  )

  total_annual_usd = local.total_monthly_usd * 12
}

resource "aws_budgets_budget" "rds_budget" {
  name         = "budget-${local.name_prefix}-mensal"
  budget_type  = "COST"
  limit_amount = tostring(var.budget_amount_monthly)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Alerta em 80% do orçamento — antecipação preventiva
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_contact_emails
  }

  # Alerta em 100% do orçamento — limite atingido
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_contact_emails
  }

  # Alerta em 110% baseado em forecast — custo projetado acima do limite
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 110
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.budget_contact_emails
  }
}
