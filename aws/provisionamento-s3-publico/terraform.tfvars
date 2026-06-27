region         = "us-east-1"
project_abbrev = "myproject"
environment    = "development"

# S3
versioning_enabled   = false
force_destroy        = false
cors_allowed_origins = ["*"]

# FinOps — estimativas mensais de uso
estimated_storage_gb             = 10
estimated_put_requests_thousands = 10
estimated_get_requests_thousands = 100
estimated_egress_gb_per_month    = 10

# Budget
budget_amount_monthly = 20
budget_contact_emails = ["josenilto@outlook.com"]

tags = {
  Project     = "myproject"
  Environment = "development"
  ManagedBy   = "Terraform"
}
