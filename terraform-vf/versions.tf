terraform {
  backend "azurerm" {
    key = "terraform.tfstate"
  }
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.96.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
}
