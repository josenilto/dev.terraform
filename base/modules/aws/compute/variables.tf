variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente: dev | staging | prod"
  type        = string
}

variable "ami_id" {
  description = "ID da AMI para a instância EC2 (ex: ami-0c02fb55956c7d316 para Amazon Linux 2023 em us-east-1)"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2 (ex: t3.micro, t3.small, t3.medium)"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "ID da subnet onde a instância será criada"
  type        = string
}

variable "security_group_ids" {
  description = "Lista de IDs dos Security Groups associados à instância"
  type        = list(string)
}

variable "key_name" {
  description = "Nome do par de chaves SSH cadastrado na AWS (deixe vazio para desabilitar acesso SSH por chave)"
  type        = string
  default     = ""
}

variable "root_volume_size_gb" {
  description = "Tamanho do volume root em GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Tipo do volume root EBS — gp3 é o mais custo-eficiente"
  type        = string
  default     = "gp3"
}

variable "user_data" {
  description = "Script de inicialização da instância (cloud-init / bash)"
  type        = string
  default     = ""
}

variable "enable_detailed_monitoring" {
  description = "Habilita monitoramento detalhado CloudWatch (custo adicional ~$3.50/mês por instância)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags extras aplicadas à instância"
  type        = map(string)
  default     = {}
}
