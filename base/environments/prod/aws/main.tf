terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # ATENÇÃO: backend remoto é OBRIGATÓRIO em prod.
  # Nunca use backend local em produção — risco de perda de state.
  #
  # backend "s3" {
  #   bucket         = "meu-projeto-tfstate"
  #   key            = "prod/aws/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

resource "random_string" "bucket_suffix" {
  length  = 6
  lower   = true
  numeric = true
  special = false
  upper   = false
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "rede" {
  source = "../../../modules/aws/rede"

  project_name          = var.project_name
  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  availability_zones    = var.availability_zones
  allowed_ingress_cidrs = var.allowed_ingress_cidrs
  tags                  = var.tags
}

module "compute" {
  source = "../../../modules/aws/compute"

  project_name               = var.project_name
  environment                = var.environment
  ami_id                     = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id
  instance_type              = var.instance_type
  subnet_id                  = module.rede.public_subnet_ids[0]
  security_group_ids         = [module.rede.default_security_group_id]
  key_name                   = var.key_name
  root_volume_size_gb        = var.root_volume_size_gb
  enable_detailed_monitoring = true   # Monitoramento detalhado sempre ativo em prod
  tags                       = var.tags
}

module "storage" {
  source = "../../../modules/aws/storage"

  project_name                         = var.project_name
  environment                          = var.environment
  bucket_suffix                        = random_string.bucket_suffix.result
  versioning_enabled                   = var.versioning_enabled
  force_destroy                        = var.force_destroy
  lifecycle_noncurrent_expiration_days = var.lifecycle_noncurrent_expiration_days
  tags                                 = var.tags
}
