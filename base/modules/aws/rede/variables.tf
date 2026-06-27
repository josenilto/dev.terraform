variable "project_name" {
  description = "Nome do projeto — compõe os nomes dos recursos (somente letras minúsculas, números e hífens)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{1,20}$", var.project_name))
    error_message = "project_name deve conter apenas letras minúsculas, números e hífens, com até 20 caracteres."
  }
}

variable "environment" {
  description = "Ambiente de implantação: dev | staging | prod"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment deve ser dev, staging ou prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block da VPC (ex: 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Lista de CIDRs para subnets públicas — uma por Availability Zone"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Lista de CIDRs para subnets privadas — uma por Availability Zone"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "Lista de AZs a usar (deve ter o mesmo número de entradas que as listas de subnets)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "allowed_ingress_cidrs" {
  description = "CIDRs que podem acessar a VPC via SSH/HTTP/HTTPS — restrinja em prod para o IP da sua empresa"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags extras aplicadas a todos os recursos de rede"
  type        = map(string)
  default     = {}
}
