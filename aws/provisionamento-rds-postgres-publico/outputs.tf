# ── Rede ──────────────────────────────────────────────────────────────────────

output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}

output "subnet_a_id" {
  description = "ID da Subnet A (AZ1 — RDS Master)"
  value       = aws_subnet.subnet_a.id
}

output "subnet_b_id" {
  description = "ID da Subnet B (AZ2 — RDS Read Replica)"
  value       = aws_subnet.subnet_b.id
}

output "security_group_id" {
  description = "ID do VPC Security Group do RDS"
  value       = aws_security_group.rds.id
}

# ── RDS Master ────────────────────────────────────────────────────────────────

output "master_identifier" {
  description = "Identifier do RDS Master"
  value       = aws_db_instance.master.identifier
}

output "master_endpoint" {
  description = "Endpoint de conexão do RDS Master (Read/Write)"
  value       = aws_db_instance.master.endpoint
}

output "master_address" {
  description = "Hostname do RDS Master"
  value       = aws_db_instance.master.address
}

output "master_port" {
  description = "Porta de conexão do RDS Master"
  value       = aws_db_instance.master.port
}

output "master_arn" {
  description = "ARN do RDS Master"
  value       = aws_db_instance.master.arn
}

output "master_availability_zone" {
  description = "Availability Zone do RDS Master"
  value       = aws_db_instance.master.availability_zone
}

# ── RDS Read Replica ──────────────────────────────────────────────────────────

output "replica_identifier" {
  description = "Identifier do RDS Read Replica"
  value       = aws_db_instance.replica.identifier
}

output "replica_endpoint" {
  description = "Endpoint de conexão do RDS Read Replica (Read-Only)"
  value       = aws_db_instance.replica.endpoint
}

output "replica_address" {
  description = "Hostname do RDS Read Replica"
  value       = aws_db_instance.replica.address
}

output "replica_port" {
  description = "Porta de conexão do RDS Read Replica"
  value       = aws_db_instance.replica.port
}

output "replica_arn" {
  description = "ARN do RDS Read Replica"
  value       = aws_db_instance.replica.arn
}

output "replica_availability_zone" {
  description = "Availability Zone do RDS Read Replica"
  value       = aws_db_instance.replica.availability_zone
}

# ── Conexão ───────────────────────────────────────────────────────────────────

output "connection_string_master" {
  description = "String de conexão PostgreSQL para o Master (Read/Write)"
  value       = "postgresql://${var.db_username}:***@${aws_db_instance.master.endpoint}/${var.db_name}"
  sensitive   = false
}

output "connection_string_replica" {
  description = "String de conexão PostgreSQL para a Read Replica (Read-Only)"
  value       = "postgresql://${var.db_username}:***@${aws_db_instance.replica.endpoint}/${var.db_name}"
  sensitive   = false
}

# ── FinOps ────────────────────────────────────────────────────────────────────

output "finops_cost_breakdown" {
  description = "Estimativa de custo mensal detalhada por componente (USD)"
  value = {
    master_instance_usd  = format("$%.2f", local.cost_master_instance)
    replica_instance_usd = format("$%.2f", local.cost_replica_instance)
    master_storage_usd   = format("$%.2f", local.cost_master_storage)
    replica_storage_usd  = format("$%.2f", local.cost_replica_storage)
    backup_storage_usd   = format("$%.2f", local.cost_backup)
    egress_usd           = format("$%.2f", local.cost_egress)
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
    db_identifier          = local.db_identifier
    replica_identifier     = local.db_replica_identifier
    region                 = var.region
    instance_class         = var.db_instance_class
    engine_version         = var.db_engine_version
    storage_gb             = var.estimated_storage_gb
    instance_hourly_price  = format("$%.4f", var.estimated_instance_hourly_price_usd)
    egress_gb_month        = var.estimated_egress_gb_per_month
    monthly_cost_usd       = format("$%.2f", local.total_monthly_usd)
    annual_cost_usd        = format("$%.2f", local.total_annual_usd)
    pricing_reference      = "https://aws.amazon.com/rds/postgresql/pricing"
  }
}

output "finops_budget_name" {
  description = "Nome do budget criado no AWS Cost Management"
  value       = aws_budgets_budget.rds_budget.name
}

output "finops_budget_amount_usd" {
  description = "Limite mensal configurado em USD"
  value       = var.budget_amount_monthly
}
