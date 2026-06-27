# ── Identificação ─────────────────────────────────────────────────────────────
project_name = "meu-projeto"
environment  = "prod"
location     = "eastus"

# ── Rede — CIDR exclusivo de prod ─────────────────────────────────────────────
vnet_address_space    = ["10.2.0.0/16"]
subnets = {
  public  = "10.2.1.0/24"
  private = "10.2.2.0/24"
}

# SEGURANÇA: substitua por CIDRs do IP corporativo ou VPN
allowed_ingress_cidrs = ["0.0.0.0/0"]   # Ex: ["203.0.113.0/24"]

# ── Compute — VM robusta para carga de produção ───────────────────────────────
vm_size              = "Standard_D2s_v3"  # 2 vCPU, 8 GB RAM (balanceado)
admin_username       = "adminuser"
admin_ssh_public_key = "ssh-rsa AAAA..."  # Chave SSH de prod (diferente da de dev)
enable_public_ip     = false              # Sem IP público — acesso via VPN/Bastion
os_disk_type         = "Premium_LRS"      # SSD Premium para prod
os_disk_size_gb      = 64

# ── Storage — máxima resiliência ──────────────────────────────────────────────
storage_account_tier     = "Standard"
storage_replication_type = "RAGRS"   # Leitura geográfica redundante (maior SLA)

# ── Tags ──────────────────────────────────────────────────────────────────────
tags = {
  Owner       = "josenilto@outlook.com"
  CostCenter  = "production"
  Criticality = "high"
}
