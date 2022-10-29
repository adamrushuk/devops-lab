terraform {

  # https://github.com/hashicorp/terraform/releases
  # https://github.com/hashicorp/terraform/blob/main/CHANGELOG.md
  required_version = ">= 1.3"

  # terraform remote state
  backend "azurerm" {
    container_name       = "terraform"
    key                  = "terraform.tfstate"
    resource_group_name  = "__TERRAFORM_STORAGE_RG__"
    storage_account_name = "__TERRAFORM_STORAGE_ACCOUNT__"
    use_oidc             = true
  }

  # providers (pin all versions)
  # versioning syntax: https://www.terraform.io/docs/language/expressions/version-constraints.html#version-constraint-syntax
  required_providers {

    # https://github.com/terraform-providers/terraform-provider-azurerm/releases
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.29.1"
    }

    # https://github.com/terraform-providers/terraform-provider-azuread/releases
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.29.0"
    }

    # https://github.com/hashicorp/terraform-provider-kubernetes/releases
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.14.0"
    }

    # https://github.com/hashicorp/terraform-provider-helm/releases
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.3"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.2"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }

    # https://registry.terraform.io/providers/hashicorp/archive/latest
    archive = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    }

    # TODO: remove template provider as deprecated (superseded by the templatefile function)
    # https://registry.terraform.io/providers/hashicorp/template/latest/docs#deprecation
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}

# https://github.com/terraform-providers/terraform-provider-azurerm/releases
provider "azurerm" {
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_oidc#configuring-the-service-principal-in-terraform
  use_oidc = true

  # TODO test "storage_use_azuread"
  # Should the AzureRM Provider use AzureAD to connect to the Storage Blob & Queue API's, rather than the SharedKey from the Storage Account?
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#storage_use_azuread
  # storage_use_azuread = true

  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/features-block
  features {
    resource_group {
      # required to cleanup velero snapshot(s) from resource group
      prevent_deletion_if_contains_resources = false
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#credentials-config
provider "kubernetes" {
  host                   = module.aks.full_object.kube_admin_config[0].host
  client_certificate     = base64decode(module.aks.full_object.kube_admin_config[0].client_certificate)
  client_key             = base64decode(module.aks.full_object.kube_admin_config[0].client_key)
  cluster_ca_certificate = base64decode(module.aks.full_object.kube_admin_config[0].cluster_ca_certificate)
}

# https://registry.terraform.io/providers/hashicorp/helm/latest/docs#credentials-config
provider "helm" {
  kubernetes {
    host                   = module.aks.full_object.kube_admin_config[0].host
    client_certificate     = base64decode(module.aks.full_object.kube_admin_config[0].client_certificate)
    client_key             = base64decode(module.aks.full_object.kube_admin_config[0].client_key)
    cluster_ca_certificate = base64decode(module.aks.full_object.kube_admin_config[0].cluster_ca_certificate)
  }
}
