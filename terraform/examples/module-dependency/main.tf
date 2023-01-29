# testing module dependency

# providers
provider "azurerm" {
  features {}
}
terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.86.0"
    }
  }
}

# module "aad_group
module "aad_group" {
  source = "./aad-group"
}

# module "aad_group
module "rg" {
  source = "./rg"
  #   object_id = module.aad_group.aad_elevated_group
  object_id = module.aad_group.aad_group_name
}

# resource "azurerm_resource_group" "example" {
#   count    = var.object_id == "" ? 0 : 1
#   name     = module.aad_group.aad_elevated_group
#   location = "uksouth"
# }
