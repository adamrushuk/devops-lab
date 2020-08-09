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

# Log Analytics
resource "azurerm_log_analytics_workspace" "aks" {
  count = var.aks_container_insights_enabled ? 1 : 0
  # The Workspace name is globally unique
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "Free"
  retention_in_days   = 7
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_log_analytics_solution" "aks" {
  count                 = var.aks_container_insights_enabled ? 1 : 0
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.aks.location
  resource_group_name   = azurerm_resource_group.aks.name
  workspace_resource_id = azurerm_log_analytics_workspace.aks[0].id
  workspace_name        = azurerm_log_analytics_workspace.aks[0].name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

# AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.azurerm_kubernetes_cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = var.prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                 = var.agent_pool_profile_name
    type                 = "VirtualMachineScaleSets"
    orchestrator_version = var.kubernetes_version
    node_count           = var.agent_pool_node_count
    vm_size              = var.agent_pool_profile_vm_size
    os_disk_size_gb      = var.agent_pool_profile_disk_size_gb
    enable_auto_scaling  = var.agent_pool_enable_auto_scaling
    min_count            = var.agent_pool_node_min_count
    max_count            = var.agent_pool_node_max_count
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

  # service_principal block: https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html#client_id
  # service_principal {
  #   client_id     = var.service_principal_client_id
  #   client_secret = var.service_principal_client_secret
  # }

  # managed identity block: https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html#type-1
  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    kube_dashboard {
      enabled = var.aks_dashboard_enabled
    }

    oms_agent {
      enabled                    = var.aks_container_insights_enabled
      log_analytics_workspace_id = var.aks_container_insights_enabled ? azurerm_log_analytics_workspace.aks[0].id : null
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
