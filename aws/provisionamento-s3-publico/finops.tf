# ── FinOps — Estimativa de Custo Mensal (AWS us-east-1, USD) ─────────────────
#
#  Preços de referência (verificar em https://aws.amazon.com/s3/pricing):
#    S3 Standard Storage : $0.023/GB/mês   (primeiros 50 TB)
#    PUT/COPY/POST/LIST  : $0.005 por 1.000 requisições
#    GET/SELECT          : $0.0004 por 1.000 requisições
#    Egress (internet)   : $0.09/GB        (primeiros 10 TB/mês)
#    Transfer IN         : $0.00           (entrada de dados é gratuita)
#
# ─────────────────────────────────────────────────────────────────────────────

locals {
  # ── Preços unitários ──────────────────────────────────────────────────────
  price_storage_per_gb      = 0.023
  price_put_per_thousand    = 0.005
  price_get_per_thousand    = 0.0004
  price_egress_per_gb       = 0.09

  # ── Custos mensais por componente ─────────────────────────────────────────
  cost_storage = var.estimated_storage_gb              * local.price_storage_per_gb
  cost_put     = var.estimated_put_requests_thousands  * local.price_put_per_thousand
  cost_get     = var.estimated_get_requests_thousands  * local.price_get_per_thousand
  cost_egress  = var.estimated_egress_gb_per_month     * local.price_egress_per_gb

  # ── Totais ────────────────────────────────────────────────────────────────
  total_monthly_usd = (
    local.cost_storage +
    local.cost_put     +
    local.cost_get     +
    local.cost_egress
  )

  total_annual_usd = local.total_monthly_usd * 12
}

resource "aws_budgets_budget" "s3_budget" {
  name         = "budget-${local.bucket_name}-mensal"
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
