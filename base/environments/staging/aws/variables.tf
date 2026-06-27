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
  default     = "staging"
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.1.11.0/24", "10.1.12.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "allowed_ingress_cidrs" {
  description = "CIDRs permitidos para SSH/HTTP/HTTPS — restrinja ao IP corporativo em staging"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ami_id" {
  type    = string
  default = ""
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "key_name" {
  type    = string
  default = ""
}

variable "root_volume_size_gb" {
  type    = number
  default = 30
}

variable "versioning_enabled" {
  type    = bool
  default = true
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "lifecycle_noncurrent_expiration_days" {
  description = "Dias para expirar versões não-correntes do bucket S3 (0 = desabilitado)"
  type        = number
  default     = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}
