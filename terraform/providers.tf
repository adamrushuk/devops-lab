# Providers (pin all versions)
# Terraform Remote State
terraform {
  required_version = ">= 0.12"
  backend "azurerm" {
    storage_account_name = "__TERRAFORM_STORAGE_ACCOUNT__"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
    access_key           = "__STORAGE_KEY__"
  }
}

provider "azurerm" {
  version = "=1.44.0"
}
