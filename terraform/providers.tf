terraform {
  # terraform remote state
  backend "azurerm" {
    access_key           = "__STORAGE_KEY__"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
    storage_account_name = "__TERRAFORM_STORAGE_ACCOUNT__"
  }

  # providers (pin all versions)
  # versioning syntax: https://www.terraform.io/docs/configuration/modules.html#module-versions
  required_providers {
    # https://github.com/hashicorp/terraform-provider-helm/releases
    helm = "2.0.2"

    # https://github.com/hashicorp/terraform-provider-kubernetes/releases
    kubernetes = "2.0.1"

    # https://github.com/terraform-providers/terraform-provider-azuread/releases
    azuread = "1.3.0"

    random = "~> 2.2" # ~> 2.2 = 2.X.Y
    tls    = "~> 2.1"
  }

  # 0.12.X
  required_version = "~> 0.12.30" # https://github.com/hashicorp/terraform/releases
}

# must include blank features block
# https://github.com/terraform-providers/terraform-provider-azurerm/releases
provider "azurerm" {
  version = "2.45.1"
  features {}
}

# use statically defined credentials
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#statically-defined-credentials
provider "kubernetes" {
  host                   = module.aks.full_object.kube_admin_config[0].host
  client_certificate     = base64decode(module.aks.full_object.kube_admin_config[0].client_certificate)
  client_key             = base64decode(module.aks.full_object.kube_admin_config[0].client_key)
  cluster_ca_certificate = base64decode(module.aks.full_object.kube_admin_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.aks.full_object.kube_admin_config[0].host
    client_certificate     = base64decode(module.aks.full_object.kube_admin_config[0].client_certificate)
    client_key             = base64decode(module.aks.full_object.kube_admin_config[0].client_key)
    cluster_ca_certificate = base64decode(module.aks.full_object.kube_admin_config[0].cluster_ca_certificate)
  }
}
