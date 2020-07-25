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
    helm       = "= 1.2.4"
    kubernetes = "= 1.11.4"
    azuread    = "~> 0.10"
    random     = "~> 2.2"
    tls        = "~> 2.1"
  }

  # 0.12.X
  required_version = "~> 0.12.29"
}

# must include blank features block
provider "azurerm" {
  version = "=2.20.0"
  features {}
}

provider "kubernetes" {
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  load_config_file       = false # when you wish not to load the local config file
}

provider "helm" {
  kubernetes {
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    load_config_file       = false
  }
}
