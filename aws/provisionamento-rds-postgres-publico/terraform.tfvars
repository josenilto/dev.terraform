region         = "us-east-1"
project_abbrev = "myproject"
environment    = "development"

# Rede
vpc_cidr            = "10.0.0.0/16"
subnet_a_cidr       = "10.0.1.0/24"
subnet_b_cidr       = "10.0.2.0/24"
az_a                = "us-east-1a"
az_b                = "us-east-1b"
allowed_cidr_blocks = ["0.0.0.0/0"]

# RDS
db_instance_class          = "db.t3.micro"
db_engine_version          = "16.1"
db_allocated_storage       = 20
db_max_allocated_storage   = 100
db_name                    = "appdb"
db_username                = "dbadmin"
db_password                = "CHANGE_ME_BEFORE_APPLY"
db_port                    = 5432
db_backup_retention_period = 7
db_deletion_protection     = false
skip_final_snapshot        = true
db_apply_immediately       = false
db_multi_az                = false
db_storage_encrypted       = true

# FinOps — estimativas mensais de uso
estimated_instance_hourly_price_usd = 0.017   # db.t3.micro us-east-1
estimated_storage_gb                = 20
estimated_backup_storage_gb         = 20
estimated_egress_gb_per_month       = 10

# Budget
budget_amount_monthly = 80
budget_contact_emails = ["josenilto@outlook.com"]

tags = {
  Project     = "myproject"
  Environment = "development"
  ManagedBy   = "Terraform"
}
