variable "project_name" {
  type = string
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.2.0.0/16"]
}

variable "subnets" {
  type = map(string)
  default = {
    public  = "10.2.1.0/24"
    private = "10.2.2.0/24"
  }
}

variable "allowed_ingress_cidrs" {
  description = "CRÍTICO: em prod, use CIDRs do IP corporativo — nunca 0.0.0.0/0"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "admin_username" {
  type    = string
  default = "adminuser"
}

variable "admin_ssh_public_key" {
  type = string
}

variable "enable_public_ip" {
  type    = bool
  default = false   # Em prod, prefira acesso via VPN ou Bastion sem IP público
}

variable "os_disk_type" {
  type    = string
  default = "Premium_LRS"
}

variable "os_disk_size_gb" {
  type    = number
  default = 64
}

variable "storage_account_tier" {
  type    = string
  default = "Standard"
}

variable "storage_replication_type" {
  description = "RAGRS = leitura geográfica redundante — máxima disponibilidade para prod"
  type        = string
  default     = "RAGRS"
}

variable "tags" {
  type    = map(string)
  default = {}
}
