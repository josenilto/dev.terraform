variable "project_name" {
  description = "Nome do projeto — compõe os nomes dos recursos"
  type        = string
}

variable "environment" {
  description = "Ambiente: dev | staging | prod"
  type        = string
}

variable "location" {
  description = "Região Azure (ex: eastus, brazilsouth, westeurope)"
  type        = string
}

variable "resource_group_name" {
  description = "Nome do Resource Group onde a rede será criada"
  type        = string
}

variable "vnet_address_space" {
  description = "Espaço de endereçamento da Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Mapa de subnets a criar: chave = nome lógico (ex: public, private), valor = CIDR"
  type        = map(string)
  default = {
    public  = "10.0.1.0/24"
    private = "10.0.2.0/24"
  }
}

variable "allowed_ingress_cidrs" {
  description = "CIDRs permitidos para SSH/HTTP/HTTPS via NSG — restrinja em prod"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags extras aplicadas a todos os recursos de rede"
  type        = map(string)
  default     = {}
}
