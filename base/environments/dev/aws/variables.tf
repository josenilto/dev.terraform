variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto (somente letras minúsculas, números e hífens)"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente"
  type        = string
  default     = "dev"
}

# ── Rede ──────────────────────────────────────────────────────────────────────

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas (uma por AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs das subnets privadas (uma por AZ)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "Availability Zones — ajuste conforme a região escolhida"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "allowed_ingress_cidrs" {
  description = "CIDRs permitidos para SSH/HTTP/HTTPS (restrinja em prod ao IP corporativo)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ── Compute ───────────────────────────────────────────────────────────────────

variable "ami_id" {
  description = "ID da AMI — deixe vazio para usar a AMI mais recente do Amazon Linux 2023"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Par de chaves SSH cadastrado na AWS (deixe vazio para não configurar)"
  type        = string
  default     = ""
}

variable "root_volume_size_gb" {
  description = "Tamanho do volume root em GB"
  type        = number
  default     = 20
}

# ── Storage ───────────────────────────────────────────────────────────────────

variable "versioning_enabled" {
  description = "Habilita versionamento no bucket S3"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Permite destruir o bucket com objetos — true em dev, false em prod"
  type        = bool
  default     = true
}

# ── Tags ──────────────────────────────────────────────────────────────────────

variable "tags" {
  description = "Tags extras aplicadas a todos os recursos"
  type        = map(string)
  default     = {}
}
