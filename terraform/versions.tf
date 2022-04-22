terraform {

  # https://www.terraform.io/docs/language/expressions/references.html#sensitive-resource-attributes
  # TODO: this currently makes builds fail intermittently
  # experiments = [provider_sensitive_attrs]

  # https://github.com/hashicorp/terraform/releases
  # https://github.com/hashicorp/terraform/blob/main/CHANGELOG.md
  required_version = ">= 0.13"

  # terraform remote state
  backend "azurerm" {
    access_key           = "__STORAGE_KEY__"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
    storage_account_name = "__TERRAFORM_STORAGE_ACCOUNT__"
  }

  # providers (pin all versions)
  # versioning syntax: https://www.terraform.io/docs/language/expressions/version-constraints.html#version-constraint-syntax
  required_providers {

    # https://github.com/terraform-providers/terraform-provider-azurerm/releases
    # v2.99.0 is the last release in the 2.x line
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.3.0"
    }

    # https://github.com/terraform-providers/terraform-provider-azuread/releases
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.21.0"
    }

    # https://github.com/hashicorp/terraform-provider-kubernetes/releases
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10.0"
    }

    # https://github.com/hashicorp/terraform-provider-helm/releases
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }

    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}

# must include blank features block
# https://github.com/terraform-providers/terraform-provider-azurerm/releases
provider "azurerm" {
  features {}
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

  # TODO: currently has issues when enabled
  # experiments {
  #   manifest = true
  # }
}
