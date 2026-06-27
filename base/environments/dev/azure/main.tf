terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # ── Backend Remoto ────────────────────────────────────────────────────────────
  # Descomente após criar a Storage Account de state no Azure.
  # Veja as instruções completas no README.md (seção "Gerenciamento de State").
  #
  # backend "azurerm" {
  #   resource_group_name  = "tfstate-rg"
  #   storage_account_name = "meuprojetotfstate"
  #   container_name       = "tfstate"
  #   key                  = "dev/azure/terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

# ── Sufixo único para a Storage Account ──────────────────────────────────────

resource "random_string" "storage_suffix" {
  length  = 6
  lower   = true
  numeric = true
  special = false
  upper   = false
}

# ── Resource Group ────────────────────────────────────────────────────────────

resource "azurerm_resource_group" "main" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location

  tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

# ── Módulo: Rede ──────────────────────────────────────────────────────────────

module "rede" {
  source = "../../../modules/azure/rede"

  project_name          = var.project_name
  environment           = var.environment
  location              = var.location
  resource_group_name   = azurerm_resource_group.main.name
  vnet_address_space    = var.vnet_address_space
  subnets               = var.subnets
  allowed_ingress_cidrs = var.allowed_ingress_cidrs
  tags                  = var.tags
}

# ── Módulo: Compute ───────────────────────────────────────────────────────────

module "compute" {
  source = "../../../modules/azure/compute"

  project_name         = var.project_name
  environment          = var.environment
  location             = var.location
  resource_group_name  = azurerm_resource_group.main.name
  vm_size              = var.vm_size
  subnet_id            = module.rede.subnet_ids["public"]
  admin_username       = var.admin_username
  admin_ssh_public_key = var.admin_ssh_public_key
  enable_public_ip     = var.enable_public_ip
  os_disk_type         = var.os_disk_type
  tags                 = var.tags
}

# ── Módulo: Storage ───────────────────────────────────────────────────────────

module "storage" {
  source = "../../../modules/azure/storage"

  project_name        = var.project_name
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  account_tier        = var.storage_account_tier
  replication_type    = var.storage_replication_type
  storage_name_suffix = random_string.storage_suffix.result
  tags                = var.tags
}
