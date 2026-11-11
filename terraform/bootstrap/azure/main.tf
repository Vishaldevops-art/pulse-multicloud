# Creates the Azure Storage Account that holds Terraform remote state.
# Run ONCE with local state:  terraform init; terraform plan; terraform apply
# Cost: a few cents/month. Keep it while you do the course; destroy at the very end.
# Needs: az login, and $env:ARM_SUBSCRIPTION_ID set to your subscription id.

terraform {
  required_version = ">= 1.10"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
    random  = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  type    = string
  default = "centralindia"
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-pulse-tfstate"
  location = var.location
  tags     = { project = "pulse-multicloud", purpose = "terraform-state" }
}

resource "azurerm_storage_account" "tfstate" {
  name                            = "stpulsetf${random_string.suffix.result}"
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true # lets you recover a corrupted/overwritten state file
  }

  tags = azurerm_resource_group.tfstate.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

output "backend_config" {
  description = "Paste into envs/azure/backend.hcl"
  value       = <<-EOT
    resource_group_name  = "${azurerm_resource_group.tfstate.name}"
    storage_account_name = "${azurerm_storage_account.tfstate.name}"
    container_name       = "tfstate"
    key                  = "azure/pulse.tfstate"
  EOT
}
