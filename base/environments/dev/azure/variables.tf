variable "project_name" {
  description = "Nome do projeto (somente letras minúsculas, números e hífens)"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Região Azure (ex: eastus, brazilsouth, westeurope)"
  type        = string
  default     = "eastus"
}

# ── Rede ──────────────────────────────────────────────────────────────────────

variable "vnet_address_space" {
  description = "Espaço de endereçamento da Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Mapa de subnets: chave = nome lógico, valor = CIDR"
  type        = map(string)
  default = {
    public  = "10.0.1.0/24"
    private = "10.0.2.0/24"
  }
}

variable "allowed_ingress_cidrs" {
  description = "CIDRs permitidos para SSH/HTTP/HTTPS via NSG"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ── Compute ───────────────────────────────────────────────────────────────────

variable "vm_size" {
  description = "Tamanho da VM Azure"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Nome do usuário administrador da VM"
  type        = string
  default     = "adminuser"
}

variable "admin_ssh_public_key" {
  description = "Conteúdo da chave pública SSH para autenticação (cat ~/.ssh/id_rsa.pub)"
  type        = string
}

variable "enable_public_ip" {
  description = "Cria um IP público para a VM"
  type        = bool
  default     = true
}

variable "os_disk_type" {
  description = "Tipo do disco do SO: Standard_LRS | StandardSSD_LRS | Premium_LRS"
  type        = string
  default     = "Standard_LRS"
}

# ── Storage ───────────────────────────────────────────────────────────────────

variable "storage_account_tier" {
  description = "Tier da Storage Account: Standard | Premium"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Tipo de replicação: LRS | ZRS | GRS | RAGRS"
  type        = string
  default     = "LRS"
}

# ── Tags ──────────────────────────────────────────────────────────────────────

variable "tags" {
  description = "Tags extras aplicadas a todos os recursos"
  type        = map(string)
  default     = {}
}
