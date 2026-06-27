resource_group_name = "rg-acr-privado"
location            = "East US"

# Nomenclatura — o nome final do ACR é gerado automaticamente:
#   acr{project_abbrev}{env_abbrev}{random_6chars}
#   Exemplo: acrfinancedev8k2m9z
project_abbrev = "finance"
environment    = "development"

# ACR
acr_sku                   = "Premium"
admin_enabled             = false
quarantine_policy_enabled = false
retention_days            = 7
trust_policy_enabled      = false

# Rede
vnet_name               = "vnet-acr-privado"
vnet_address_space      = ["10.0.0.0/16"]
subnet_name             = "snet-private-endpoint"
subnet_address_prefixes = ["10.0.1.0/24"]

# FinOps — estimativas mensais de uso
estimated_storage_gb                   = 50
estimated_build_minutes_per_month      = 0
estimated_monthly_dns_queries_millions = 1
estimated_egress_gb_per_month          = 10

tags = {
  environment = "development"
  project     = "acr-privado"
  managed_by  = "terraform"
}
