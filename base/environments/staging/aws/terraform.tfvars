# ── Identificação ─────────────────────────────────────────────────────────────
aws_region   = "us-east-1"
project_name = "meu-projeto"
environment  = "staging"

# ── Rede — CIDR diferente de dev para evitar sobreposição ─────────────────────
vpc_cidr              = "10.1.0.0/16"
public_subnet_cidrs   = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs  = ["10.1.11.0/24", "10.1.12.0/24"]
availability_zones    = ["us-east-1a", "us-east-1b"]
allowed_ingress_cidrs = ["0.0.0.0/0"]  # Restrinja ao IP corporativo em ambientes reais

# ── Compute — instância maior que dev ────────────────────────────────────────
ami_id              = ""           # Usa Amazon Linux 2023 mais recente automaticamente
instance_type       = "t3.small"   # Mais recursos que dev para testes de performance
key_name            = ""
root_volume_size_gb = 30           # Disco maior para carga de testes

# ── Storage — versionamento ativo ────────────────────────────────────────────
versioning_enabled                   = true
force_destroy                        = false   # Protege dados de testes
lifecycle_noncurrent_expiration_days = 30      # Expira versões antigas após 30 dias

# ── Tags ──────────────────────────────────────────────────────────────────────
tags = {
  Owner      = "josenilto@outlook.com"
  CostCenter = "staging"
}
