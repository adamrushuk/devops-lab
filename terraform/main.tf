# Common
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_resource_group" "aks" {
  name     = var.azure_resourcegroup_name
  location = var.location
  tags     = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}


# ACR
resource "azurerm_container_registry" "aks" {
  name                = var.container_registry_name
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  admin_enabled       = var.acr_admin_enabled
  sku                 = var.acr_sku
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}


# Log Analytics
resource "azurerm_log_analytics_workspace" "aks" {
  # The Workspace name is globally unique
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "PerGB2018"
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_log_analytics_solution" "aks" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.aks.location
  resource_group_name   = azurerm_resource_group.aks.name
  workspace_resource_id = azurerm_log_analytics_workspace.aks.id
  workspace_name        = azurerm_log_analytics_workspace.aks.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.azurerm_kubernetes_cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = var.aks_dns_prefix

  default_node_pool {
    name                = var.agent_pool_profile_name
    type                = "VirtualMachineScaleSets"
    node_count          = var.agent_pool_node_count
    vm_size             = var.agent_pool_profile_vm_size
    os_disk_size_gb     = var.agent_pool_profile_disk_size_gb
    enable_auto_scaling = var.agent_pool_enable_auto_scaling
    min_count           = var.agent_pool_node_min_count
    max_count           = var.agent_pool_node_max_count
  }

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = chomp(
        coalesce(
          var.ssh_public_key,
          tls_private_key.ssh.public_key_openssh,
        )
      )
    }
  }

  service_principal {
    client_id     = var.service_principal_client_id
    client_secret = var.service_principal_client_secret
  }

  addon_profile {
    kube_dashboard {
      enabled = var.enable_aks_dashboard
    }

    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      service_principal,
      default_node_pool[0].node_count,
      tags,
      # addon_profile,
    ]
  }
}
