# AKS
# https://registry.terraform.io/modules/adamrushuk/aks/azurerm/latest

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

# NOTE: Requires "Azure Active Directory Graph" "Directory.ReadWrite.All" Application API permission to create, and
# also requires "User Access Administrator" role to delete
# ! You can assign one of the required Azure Active Directory Roles with the AzureAD PowerShell Module
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group
resource "azuread_group" "aks_admins" {
  display_name            = "${var.azurerm_kubernetes_cluster_name}-aks-administrators"
  description             = "${var.azurerm_kubernetes_cluster_name} Kubernetes cluster administrators"
  prevent_duplicate_names = true
  security_enabled        = true
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                              = var.azurerm_kubernetes_cluster_name
  location                          = azurerm_resource_group.aks.location
  resource_group_name               = azurerm_resource_group.aks.name
  dns_prefix                        = var.azurerm_kubernetes_cluster_name
  kubernetes_version                = var.kubernetes_version
  sku_tier                          = "Free"
  role_based_access_control_enabled = true
  tags                              = var.tags

  default_node_pool {
    name                 = "default"
    orchestrator_version = var.kubernetes_version
    vm_size              = var.agent_pool_profile_vm_size
    node_count           = 1
    max_pods             = 90
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

  # managed identity block
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#identity
  identity {
    type = "SystemAssigned"
  }

  # https://docs.microsoft.com/en-us/azure/aks/azure-ad-rbac
  azure_active_directory_role_based_access_control {
    managed = true
    admin_group_object_ids = [
      azuread_group.aks_admins.id
    ]
  }

  # https://docs.microsoft.com/en-ie/azure/governance/policy/concepts/policy-for-kubernetes
  azure_policy_enabled = false

  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#oms_agent
  # conditional dynamic block
  dynamic "oms_agent" {
    for_each = var.aks_container_insights_enabled == true ? [1] : []
    content {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks[0].id
    }
  }

  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#network_plugin
  network_profile {
    load_balancer_sku  = "basic"
    outbound_type      = "loadBalancer"
    network_plugin     = "azure"
    network_policy     = "azure"
    service_cidr       = "10.0.0.0/16"
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#workload_identity_enabled
  # https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster#register-the-enableworkloadidentitypreview-feature-flag
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
}

# Add role to access AKS Resource View
# https://docs.microsoft.com/en-us/azure/aks/kubernetes-portal
resource "azurerm_role_assignment" "aks_portal_resource_view" {
  principal_id         = azuread_group.aks_admins.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  scope                = azurerm_kubernetes_cluster.aks.id
}

# Add existing AAD group as a member to the <AKS_CLUSTER_NAME>-aks-administrators group
data "azuread_group" "existing_aks_admins" {
  display_name     = var.aks_admins_aad_group_name
  security_enabled = true
}

resource "azuread_group_member" "existing_aks_admins" {
  group_object_id  = azuread_group.aks_admins.id
  member_object_id = data.azuread_group.existing_aks_admins.id
}

# AKS module
# https://registry.terraform.io/modules/adamrushuk/aks/azurerm/latest
# module "aks" {
#   source  = "adamrushuk/aks/azurerm"
#   version = "~> 1.1.0"

#   kubernetes_version   = var.kubernetes_version
#   location             = azurerm_resource_group.aks.location
#   resource_group_name  = azurerm_resource_group.aks.name
#   name                 = var.azurerm_kubernetes_cluster_name
#   sla_sku              = var.sla_sku
#   aad_auth_enabled     = true
#   azure_policy_enabled = true
#   tags                 = var.tags

#   # override defaults
#   default_node_pool = {
#     name                 = var.agent_pool_profile_name
#     count                = var.agent_pool_node_count
#     orchestrator_version = var.kubernetes_version
#     vm_size              = var.agent_pool_profile_vm_size
#     enable_auto_scaling  = var.agent_pool_enable_auto_scaling
#     max_count            = var.agent_pool_node_max_count
#     max_pods             = 90
#     min_count            = var.agent_pool_node_min_count
#     os_disk_size_gb      = var.agent_pool_profile_disk_size_gb
#   }

#   # add-ons
#   log_analytics_workspace_id = var.aks_container_insights_enabled == true ? azurerm_log_analytics_workspace.aks[0].id : ""

#   # Add existing group to the new AKS cluster admin group
#   aks_admin_group_member_name = var.aks_admins_aad_group_name
# }
