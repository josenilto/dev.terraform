output "bucket_name" {
  description = "Nome do bucket S3 público criado"
  value       = aws_s3_bucket.public.bucket
}

output "bucket_arn" {
  description = "ARN do bucket S3"
  value       = aws_s3_bucket.public.arn
}

output "bucket_domain_name" {
  description = "Endpoint público do bucket (domínio S3 global)"
  value       = aws_s3_bucket.public.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Endpoint regional do bucket"
  value       = aws_s3_bucket.public.bucket_regional_domain_name
}

output "finops_cost_breakdown" {
  description = "Estimativa de custo mensal detalhada por componente (USD)"
  value = {
    storage_usd      = format("$%.2f", local.cost_storage)
    put_requests_usd = format("$%.2f", local.cost_put)
    get_requests_usd = format("$%.2f", local.cost_get)
    egress_usd       = format("$%.2f", local.cost_egress)
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
    bucket_name            = local.bucket_name
    region                 = var.region
    estimated_storage_gb   = var.estimated_storage_gb
    put_requests_thousands = var.estimated_put_requests_thousands
    get_requests_thousands = var.estimated_get_requests_thousands
    egress_gb_month        = var.estimated_egress_gb_per_month
    monthly_cost_usd       = format("$%.2f", local.total_monthly_usd)
    annual_cost_usd        = format("$%.2f", local.total_annual_usd)
    pricing_reference      = "https://aws.amazon.com/s3/pricing"
  }
}

output "finops_budget_name" {
  description = "Nome do budget criado no AWS Cost Management"
  value       = aws_budgets_budget.s3_budget.name
}

output "finops_budget_amount_usd" {
  description = "Limite mensal configurado em USD"
  value       = var.budget_amount_monthly
}
