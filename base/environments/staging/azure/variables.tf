variable "project_name" {
  type = string
}

variable "environment" {
  type    = string
  default = "staging"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.1.0.0/16"]
}

variable "subnets" {
  type = map(string)
  default = {
    public  = "10.1.1.0/24"
    private = "10.1.2.0/24"
  }
}

variable "allowed_ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "admin_username" {
  type    = string
  default = "adminuser"
}

variable "admin_ssh_public_key" {
  description = "Conteúdo da chave pública SSH"
  type        = string
}

variable "enable_public_ip" {
  type    = bool
  default = true
}

variable "os_disk_type" {
  type    = string
  default = "StandardSSD_LRS"
}

variable "storage_account_tier" {
  type    = string
  default = "Standard"
}

variable "storage_replication_type" {
  type    = string
  default = "GRS"
}

variable "tags" {
  type    = map(string)
  default = {}
}
