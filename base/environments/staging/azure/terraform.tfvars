# ── Identificação ─────────────────────────────────────────────────────────────
project_name = "meu-projeto"
environment  = "staging"
location     = "eastus"

# ── Rede — CIDR diferente de dev ─────────────────────────────────────────────
vnet_address_space    = ["10.1.0.0/16"]
subnets = {
  public  = "10.1.1.0/24"
  private = "10.1.2.0/24"
}
allowed_ingress_cidrs = ["0.0.0.0/0"]

# ── Compute — VM maior para testes ───────────────────────────────────────────
vm_size              = "Standard_B2s"      # 2 vCPU, 4 GB RAM
admin_username       = "adminuser"
admin_ssh_public_key = "ssh-rsa AAAA..."   # Cole aqui o conteúdo de ~/.ssh/id_rsa.pub
enable_public_ip     = true
os_disk_type         = "StandardSSD_LRS"   # SSD para melhor latência em testes

# ── Storage — replicação geográfica ──────────────────────────────────────────
storage_account_tier     = "Standard"
storage_replication_type = "GRS"   # Replicação geográfica para staging

# ── Tags ──────────────────────────────────────────────────────────────────────
tags = {
  Owner      = "josenilto@outlook.com"
  CostCenter = "staging"
}
