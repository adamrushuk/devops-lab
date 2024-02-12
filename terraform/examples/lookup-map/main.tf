# Create all possible combinations from two lists, and loop through result to assign roles
# https://www.terraform.io/docs/language/functions/setproduct.html

provider "azurerm" {
  features {}
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.91.0"
    }
  }
}

locals {
  region = "primary"

  # Primary Region
  primary_location_abbr = "E1"
  primary = {
    location      = "eastus"
    location_abbr = local.primary_location_abbr
    resource_name_prefix = "${local.primary_location_abbr}-"
    tags = {
      source = "terraform"
    }
  }
  # Secondary Region
  secondary_location_abbr = "C1"
  secondary = {
    location      = "centralus"
    location_abbr = local.secondary_location_abbr
    resource_name_prefix = "${local.secondary_location_abbr}-"
    tags = {
      source = "terraform"
    }
  }
}

variable "locals_map_path" {
  description = "Defines the path for the locals map"
  type = string
  default = "local.primary"
}
