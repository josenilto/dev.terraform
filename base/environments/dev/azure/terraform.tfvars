# ── Identificação ─────────────────────────────────────────────────────────────
project_name = "meu-projeto"   # Altere para o nome real do seu projeto
environment  = "dev"
location     = "eastus"        # Outras opções: brazilsouth, westeurope

# ── Rede ──────────────────────────────────────────────────────────────────────
vnet_address_space    = ["10.0.0.0/16"]
subnets = {
  public  = "10.0.1.0/24"
  private = "10.0.2.0/24"
}
allowed_ingress_cidrs = ["0.0.0.0/0"]  # Em prod: substitua pelo IP da sua empresa

# ── Compute ───────────────────────────────────────────────────────────────────
vm_size              = "Standard_B1s"   # Menor tamanho disponível (~$8/mês em eastus)
admin_username       = "adminuser"
admin_ssh_public_key = "ssh-rsa AAAA..."  # Cole aqui o conteúdo de ~/.ssh/id_rsa.pub
enable_public_ip     = true
os_disk_type         = "Standard_LRS"

# ── Storage ───────────────────────────────────────────────────────────────────
storage_account_tier     = "Standard"
storage_replication_type = "LRS"   # LRS em dev; GRS em prod para maior resiliência

# ── Tags ──────────────────────────────────────────────────────────────────────
tags = {
  Owner      = "josenilto@outlook.com"
  CostCenter = "dev-labs"
}
