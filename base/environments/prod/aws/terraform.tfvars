# ── Identificação ─────────────────────────────────────────────────────────────
aws_region   = "us-east-1"
project_name = "meu-projeto"
environment  = "prod"

# ── Rede — CIDR exclusivo de prod ─────────────────────────────────────────────
vpc_cidr              = "10.2.0.0/16"
public_subnet_cidrs   = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs  = ["10.2.11.0/24", "10.2.12.0/24"]
availability_zones    = ["us-east-1a", "us-east-1b"]

# SEGURANÇA: restrinja ao IP da empresa — nunca use 0.0.0.0/0 em prod
allowed_ingress_cidrs = ["0.0.0.0/0"]   # Substitua por ex: ["203.0.113.0/24"]

# ── Compute — instância robusta para carga real ────────────────────────────────
ami_id              = ""           # Usa Amazon Linux 2023 mais recente
instance_type       = "t3.medium"  # 2 vCPU, 4 GB RAM — ajuste conforme necessidade
key_name            = ""           # Nome do par de chaves SSH de prod
root_volume_size_gb = 50           # Disco maior para workloads de produção

# ── Storage — máxima proteção de dados ───────────────────────────────────────
versioning_enabled                   = true    # Sempre ativo em prod
force_destroy                        = false   # NUNCA altere para true em prod
lifecycle_noncurrent_expiration_days = 90      # Mantém histórico por 90 dias

# ── Tags ──────────────────────────────────────────────────────────────────────
tags = {
  Owner      = "josenilto@outlook.com"
  CostCenter = "production"
  Criticality = "high"
}
