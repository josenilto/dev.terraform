# ── Identificação ─────────────────────────────────────────────────────────────
aws_region   = "us-east-1"
project_name = "meu-projeto"   # Altere para o nome real do seu projeto
environment  = "dev"

# ── Rede ──────────────────────────────────────────────────────────────────────
vpc_cidr              = "10.0.0.0/16"
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24"]
availability_zones    = ["us-east-1a", "us-east-1b"]
allowed_ingress_cidrs = ["0.0.0.0/0"]  # Em prod: substitua pelo IP da sua empresa

# ── Compute ───────────────────────────────────────────────────────────────────
ami_id              = ""           # Vazio = usa Amazon Linux 2023 mais recente
instance_type       = "t3.micro"   # t3.micro é elegível ao Free Tier
key_name            = ""           # Nome do par de chaves SSH cadastrado na AWS
root_volume_size_gb = 20

# ── Storage ───────────────────────────────────────────────────────────────────
versioning_enabled = false   # Habilite em staging e prod
force_destroy      = true    # Só use true em dev — protege dados em prod

# ── Tags ──────────────────────────────────────────────────────────────────────
tags = {
  Owner      = "josenilto@outlook.com"
  CostCenter = "dev-labs"
}
