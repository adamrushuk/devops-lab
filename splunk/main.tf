terraform {
  required_version = ">= 0.13"

  required_providers {
    # https://github.com/terraform-providers/terraform-provider-azurerm/releases
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.63.0"
    }

    # https://github.com/terraform-providers/terraform-provider-azuread/releases
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.5.1"
    }

    # https://github.com/hashicorp/terraform-provider-kubernetes/releases
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.3.2"
    }

    # https://github.com/hashicorp/terraform-provider-helm/releases
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_string" "aks" {
  length  = 4
  special = false
  upper   = false
}

locals {
  # version used for both main AKS API service, and default node pool
  # https://github.com/Azure/AKS/releases
  # az aks get-versions --location uksouth --output table
  kubernetes_version  = "1.18.19"
  location            = "uksouth"
  # prefix              = "ar${random_string.aks.result}" # aks dns_prefix must start with a letter
  prefix              = "arsplunk" # aks dns_prefix must start with a letter
  resource_group_name = "${local.prefix}-rg-azurerm-kubernetes-cluster"
  name                = "${local.prefix}-aks-cluster"

  tags = {
    App    = "splunk"
    Env    = "Dev"
    Owner  = "Adam Rush"
    Source = "terraform"
  }
}

resource "azurerm_resource_group" "aks" {
  name     = local.resource_group_name
  location = local.location
  tags     = local.tags
}

module "aks" {
  source = "adamrushuk/aks/azurerm"

  kubernetes_version  = local.kubernetes_version
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  name                = local.name
  tags                = local.tags

  # Add existing group to the new AKS cluster admin group
  aks_admin_group_member_name = "AKS-Admins"

  # override defaults
  default_node_pool = {
    vm_size  = "Standard_D4s_v3"
    count    = 1
    max_pods = 99
  }
}

output "aks_credentials_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.aks.name} --name ${module.aks.name} --overwrite-existing  --admin"
}

output "full_object" {
  value     = module.aks.full_object
  sensitive = true
}
