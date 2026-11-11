# Azure environment root. Init with:  terraform init -backend-config=backend.hcl
# (backend.hcl comes from the bootstrap/azure output and is git-ignored)

terraform {
  required_version = ">= 1.10"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

variable "location" {
  type    = string
  default = "centralindia"
}

# Week 4 - uncomment as you build the modules.
# module "network" {
#   source        = "../../modules/azure-network"
#   name          = "pulse"
#   location      = var.location
#   address_space = ["10.10.0.0/16"]
# }
#
# module "aks" {
#   source              = "../../modules/azure-aks"
#   name                = "pulse"
#   location            = var.location
#   resource_group_name = module.network.resource_group_name
#   subnet_id           = module.network.aks_subnet_id
# }
