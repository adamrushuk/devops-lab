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
    helm       = "= 1.3.0"  # https://github.com/hashicorp/terraform-provider-helm/releases
    kubernetes = "= 1.13.2" # https://github.com/hashicorp/terraform-provider-kubernetes/releases
    azuread    = "= 1.0.0" # https://github.com/terraform-providers/terraform-provider-azuread/releases
    random     = "~> 2.2"   # ~> 2.2 = 2.X.Y
    tls        = "~> 2.1"
  }

  # 0.12.X
  required_version = "~> 0.12.29" # https://github.com/hashicorp/terraform/releases
}

# must include blank features block
provider "azurerm" {
  version = "=2.27.0" # https://github.com/terraform-providers/terraform-provider-azurerm/releases
  features {}
}

# use statically defined credentials
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#statically-defined-credentials
provider "kubernetes" {
  load_config_file       = false # when you wish not to load the local config file
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    load_config_file       = false
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}
