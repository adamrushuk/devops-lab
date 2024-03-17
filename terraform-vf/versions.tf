terraform {
  backend "azurerm" {
    container_name = "terraform"
    key            = "terraform.tfstate"
    use_oidc       = true # or use "ARM_USE_OIDC" env var
    # requires "Storage Blob Data Contributor" on the container
    use_azuread_auth = true
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
