locals {
  # Estimativa de custo mensal por SKU (USD) — valores de referência Azure Pricing
  acr_cost_estimate = {
    Basic    = { registry = 5.00,  storage_per_gb = 0.10, ops_per_10k = 0.01 }
    Standard = { registry = 20.00, storage_per_gb = 0.10, ops_per_10k = 0.01 }
    Premium  = { registry = 50.00, storage_per_gb = 0.10, ops_per_10k = 0.01 }
  }

  sku_cost = local.acr_cost_estimate[var.acr_sku]
}

resource "azurerm_consumption_budget_resource_group" "acr_budget" {
  name              = "budget-${local.acr_name}-mensal"
  resource_group_id = azurerm_resource_group.rg.id

  amount     = var.budget_amount_monthly
  time_grain = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  # Alerta em 80% do orçamento — antecipação preventiva
  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = var.budget_contact_emails
  }

  # Alerta em 100% do orçamento — limite atingido
  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = var.budget_contact_emails
  }

  # Alerta em 110% baseado em forecast — custo projetado acima do limite
  notification {
    enabled        = true
    threshold      = 110
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = var.budget_contact_emails
  }
}
