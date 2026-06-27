# ── FinOps — Estimativa de Custo Mensal (Azure East US, USD) ─────────────────
#
#  Preços de referência (verificar em https://azure.microsoft.com/pricing):
#    ACR Premium  : $0.667/dia
#    Storage extra: $0.0034/GiB/dia  (Premium inclui 500 GiB)
#    Build Tasks  : $0.0001/segundo  ($0.006/minuto)
#    DNS Zone     : $0.50/zona/mês
#    DNS Queries  : $0.40/milhão de consultas
#    Egress       : $0.087/GB (primeiros 10 TB/mês)
#
# ─────────────────────────────────────────────────────────────────────────────

locals {
  days_per_month = 30

  # ── Preços unitários ──────────────────────────────────────────────────────
  price_acr_premium_per_day       = 0.667
  price_storage_per_gb_per_day    = 0.0034
  price_build_per_minute          = 0.006
  price_dns_zone_per_month        = 0.50
  price_dns_queries_per_million   = 0.40
  price_egress_per_gb             = 0.087

  # ── Cálculo de armazenamento extra (Premium inclui 500 GB) ───────────────
  storage_included_gb  = 500
  storage_extra_gb     = max(0, var.estimated_storage_gb - local.storage_included_gb)

  # ── Custos mensais por componente ─────────────────────────────────────────
  cost_acr_registry = local.price_acr_premium_per_day * local.days_per_month
  cost_storage      = local.storage_extra_gb * local.price_storage_per_gb_per_day * local.days_per_month
  cost_build        = var.estimated_build_minutes_per_month * local.price_build_per_minute
  cost_dns_zone     = local.price_dns_zone_per_month
  cost_dns_queries  = var.estimated_monthly_dns_queries_millions * local.price_dns_queries_per_million
  cost_egress       = var.estimated_egress_gb_per_month * local.price_egress_per_gb

  # ── Totais ────────────────────────────────────────────────────────────────
  total_monthly_usd = (
    local.cost_acr_registry +
    local.cost_storage      +
    local.cost_build        +
    local.cost_dns_zone     +
    local.cost_dns_queries  +
    local.cost_egress
  )

  total_annual_usd = local.total_monthly_usd * 12
}

output "finops_cost_breakdown" {
  description = "Estimativa de custo mensal detalhada por componente (USD)"
  value = {
    acr_registry_premium_usd = format("$%.2f", local.cost_acr_registry)
    storage_extra_usd        = format("$%.2f", local.cost_storage)
    build_tasks_usd          = format("$%.2f", local.cost_build)
    private_dns_zone_usd     = format("$%.2f", local.cost_dns_zone)
    dns_queries_usd          = format("$%.2f", local.cost_dns_queries)
    egress_usd               = format("$%.2f", local.cost_egress)
  }
}

output "finops_monthly_total_usd" {
  description = "Custo mensal total estimado (USD)"
  value       = format("$%.2f", local.total_monthly_usd)
}

output "finops_annual_total_usd" {
  description = "Custo anual total estimado (USD)"
  value       = format("$%.2f", local.total_annual_usd)
}

output "finops_summary" {
  description = "Resumo FinOps com premissas de cálculo"
  value = {
    acr_name              = local.acr_name
    sku                   = var.acr_sku
    region                = var.location
    estimated_storage_gb  = var.estimated_storage_gb
    storage_included_gb   = local.storage_included_gb
    storage_extra_gb      = local.storage_extra_gb
    build_minutes_month   = var.estimated_build_minutes_per_month
    dns_queries_millions  = var.estimated_monthly_dns_queries_millions
    egress_gb_month       = var.estimated_egress_gb_per_month
    monthly_cost_usd      = format("$%.2f", local.total_monthly_usd)
    annual_cost_usd       = format("$%.2f", local.total_annual_usd)
    pricing_reference     = "https://azure.microsoft.com/pricing/details/container-registry"
  }
}
