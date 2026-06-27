resource_group_name = "rg-acr-publico"
location            = "East US"
project_prefix      = "devops"
acr_sku             = "Basic"
admin_enabled       = true

# FinOps
budget_amount_monthly = 30
budget_start_date     = "2026-06-01T00:00:00Z"
budget_contact_emails = ["josenilto@outlook.com"]

tags = {
  environment = "dev"
  project     = "acr-publico"
  managed_by  = "terraform"
  cost_center = "infra"
}
