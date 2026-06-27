variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente: dev | staging | prod"
  type        = string
}

variable "location" {
  description = "Região Azure"
  type        = string
}

variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "vm_size" {
  description = "Tamanho da VM Azure (ex: Standard_B1s = 1 vCPU/1 GB, Standard_B2s = 2 vCPU/4 GB)"
  type        = string
  default     = "Standard_B1s"
}

variable "subnet_id" {
  description = "ID da subnet onde a interface de rede será conectada"
  type        = string
}

variable "admin_username" {
  description = "Nome do usuário administrador da VM"
  type        = string
  default     = "adminuser"
}

variable "admin_ssh_public_key" {
  description = "Conteúdo da chave pública SSH (conteúdo de ~/.ssh/id_rsa.pub)"
  type        = string
}

variable "os_disk_type" {
  description = "Tipo do disco do SO: Standard_LRS | StandardSSD_LRS | Premium_LRS"
  type        = string
  default     = "Standard_LRS"
}

variable "os_disk_size_gb" {
  description = "Tamanho do disco do SO em GB"
  type        = number
  default     = 30
}

variable "source_image_publisher" {
  description = "Publisher da imagem de SO"
  type        = string
  default     = "Canonical"
}

variable "source_image_offer" {
  description = "Oferta da imagem de SO"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "source_image_sku" {
  description = "SKU da imagem de SO (Ubuntu 22.04 LTS Gen2)"
  type        = string
  default     = "22_04-lts-gen2"
}

variable "source_image_version" {
  description = "Versão da imagem (latest = sempre usa a mais recente)"
  type        = string
  default     = "latest"
}

variable "enable_public_ip" {
  description = "Cria e associa um IP público estático à VM"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags extras aplicadas à VM e recursos associados"
  type        = map(string)
  default     = {}
}
