# Common
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_resource_group" "aks" {
  name     = var.azure_resourcegroup_name
  location = var.location
  tags     = var.tags
}

# Log Analytics
resource "azurerm_log_analytics_workspace" "aks" {
  count = var.aks_container_insights_enabled ? 1 : 0

  # The Workspace name is globally unique
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_log_analytics_solution" "aks" {
  count = var.aks_container_insights_enabled ? 1 : 0

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
# https://registry.terraform.io/modules/adamrushuk/aks/azurerm/latest
module "aks" {
  source  = "adamrushuk/aks/azurerm"
  version = "~> 1.0.0"

  kubernetes_version   = var.kubernetes_version
  location             = azurerm_resource_group.aks.location
  resource_group_name  = azurerm_resource_group.aks.name
  name                 = var.azurerm_kubernetes_cluster_name
  sla_sku              = var.sla_sku
  aad_auth_enabled     = true
  azure_policy_enabled = true
  tags                 = var.tags

  # override defaults
  default_node_pool = {
    name                 = var.agent_pool_profile_name
    count                = var.agent_pool_node_count
    orchestrator_version = var.kubernetes_version
    vm_size              = var.agent_pool_profile_vm_size
    enable_auto_scaling  = var.agent_pool_enable_auto_scaling
    max_count            = var.agent_pool_node_max_count
    max_pods             = 90
    min_count            = var.agent_pool_node_min_count
    os_disk_size_gb      = var.agent_pool_profile_disk_size_gb
  }

  # add-ons
  log_analytics_workspace_id = var.aks_container_insights_enabled == true ? azurerm_log_analytics_workspace.aks[0].id : ""

  # Add existing group to the new AKS cluster admin group
  aks_admin_group_member_name = var.aks_admins_aad_group_name
}
