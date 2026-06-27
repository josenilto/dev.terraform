variable "aws_region" {
  description = "Região AWS onde os recursos serão provisionados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto para identificação e tagging FinOps"
  type        = string
  default     = "eks-nuvem-privada"
}

variable "environment" {
  description = "Ambiente de implantação (dev, staging, prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "O ambiente deve ser: dev, staging ou prod."
  }
}

variable "cost_center" {
  description = "Centro de custo para alocação FinOps"
  type        = string
  default     = "CC-1001"
}

variable "owner" {
  description = "Responsável pelo recurso (e-mail)"
  type        = string
  default     = "infra-team@empresa.com"
}

variable "team" {
  description = "Time responsável pelo recurso"
  type        = string
  default     = "platform-engineering"
}

# VPC
variable "vpc_cidr" {
  description = "CIDR block da VPC principal do EKS"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "CIDRs das subnets privadas (uma por AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "CIDRs das subnets públicas (NAT Gateway)"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "availability_zones" {
  description = "Zonas de disponibilidade"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# EKS
variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
  default     = "eks-privado"
}

variable "cluster_version" {
  description = "Versão do Kubernetes no EKS"
  type        = string
  default     = "1.29"
}

# Node Groups — Managed
variable "managed_node_instance_types" {
  description = "Tipos de instância para o node group gerenciado"
  type        = list(string)
  default     = ["t3.medium", "t3.large"]
}

variable "managed_node_desired" {
  description = "Número desejado de nós gerenciados"
  type        = number
  default     = 2
}

variable "managed_node_min" {
  description = "Número mínimo de nós gerenciados (FinOps: evitar ociosidade)"
  type        = number
  default     = 1
}

variable "managed_node_max" {
  description = "Número máximo de nós gerenciados (FinOps: limitar escala)"
  type        = number
  default     = 5
}

# Node Groups — Self-managed
variable "self_managed_node_instance_types" {
  description = "Tipos de instância para o node group self-managed"
  type        = list(string)
  default     = ["m5.large", "m5a.large"]
}

variable "self_managed_node_desired" {
  description = "Número desejado de nós self-managed"
  type        = number
  default     = 2
}

variable "self_managed_node_min" {
  description = "Número mínimo de nós self-managed"
  type        = number
  default     = 1
}

variable "self_managed_node_max" {
  description = "Número máximo de nós self-managed"
  type        = number
  default     = 4
}

# Fargate
variable "fargate_namespaces" {
  description = "Namespaces Kubernetes que executam em Fargate"
  type        = list(string)
  default     = ["kube-system", "fargate-workloads"]
}

# ECR
variable "ecr_repositories" {
  description = "Repositórios ECR a serem criados"
  type        = list(string)
  default     = ["app-backend", "app-frontend", "app-worker"]
}

variable "ecr_image_retention_count" {
  description = "Número máximo de imagens retidas por repositório ECR (FinOps: reduz custo de armazenamento)"
  type        = number
  default     = 30
}

# FinOps — Budget
variable "monthly_budget_limit" {
  description = "Limite mensal de custo em USD para alertas de orçamento"
  type        = string
  default     = "500"
}

variable "budget_alert_threshold_pct" {
  description = "Percentual do orçamento para disparo de alerta"
  type        = number
  default     = 80
}

variable "budget_alert_emails" {
  description = "E-mails que recebem alertas de orçamento FinOps"
  type        = list(string)
  default     = ["finops@empresa.com", "infra-lead@empresa.com"]
}

# On-premises VPN
variable "onprem_cidr" {
  description = "CIDR da rede on-premises para regras de acesso"
  type        = string
  default     = "192.168.0.0/16"
}
