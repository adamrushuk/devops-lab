# Helm charts
variable "nginx_chart_version" {
  default = "1.36.3"
}

variable "cert_manager_chart_version" {
  default = "v0.15.0-alpha.2"
}

variable "velero_chart_version" {
  default = "2.9.15"
}


# Common
variable "location" {
  default = "__LOCATION__"
}

variable "azure_resourcegroup_name" {
  default = "__AKS_RG_NAME__"
}

variable "log_analytics_workspace_name" {
  default = "__PREFIX__-la-workspace-001"
}

variable "admin_username" {
  description = "The admin username of the VMs that will be deployed"
  default     = "sysadmin"
}


# Use "cat ~/.ssh/id_rsa.pub"
variable "ssh_public_key" {
  description = "Public key for SSH access to the VMs"
  default     = ""
}

# [NOT USED] Use "cat ~/.ssh/id_rsa"
# variable "ssh_private_key" {
#   description = "Private key for SSH access to the VMs"
#   default     = ""
# }

variable "tags" {
  description = "A map of the tags to use on the resources"

  default = {
    Env    = "Dev"
    Owner  = "Adam Rush"
    Source = "terraform"
  }
}


# AKS
variable "kubernetes_version" {
  default = "1.15.10"
}

variable "aks_dns_prefix" {
  default = "__PREFIX__"
}

variable "azurerm_kubernetes_cluster_name" {
  default = "__AKS_CLUSTER_NAME__"
}

variable "aks_dashboard_enabled" {
  description = "Should Kubernetes dashboard be enabled"
  default     = true
}

variable "aks_container_insights_enabled" {
  description = "Should Container Insights monitoring be enabled"
  default     = false
}

# Service Principle for AKS
variable "service_principal_client_id" {
  default = "__ARM_CLIENT_ID__"
}

variable "service_principal_client_secret" {
  default = "__ARM_CLIENT_SECRET__"
}

# Agent Pool
variable "agent_pool_node_count" {
  default = 1
}

variable "agent_pool_enable_auto_scaling" {
  default = true
}

variable "agent_pool_node_min_count" {
  default = 1
}

variable "agent_pool_node_max_count" {
  default = 3
}

variable "agent_pool_profile_name" {
  default = "default"
}

variable "agent_pool_profile_vm_size" {
  default = "Standard_D1_v2"
}

variable "agent_pool_profile_os_type" {
  default = "Linux"
}

variable "agent_pool_profile_disk_size_gb" {
  default = 30
}


# Velero
variable "velero_resource_group_name" {
  default = "__VELERO_STORAGE_RG__"
}

variable "velero_storage_account_name" {
  default = "__VELERO_STORAGE_ACCOUNT__"
}

variable "credentials_velero" {
  default = "NOT_DEFINED"
}


# ? Removed as now using kubernetes external-dns
# ? keeping for reference of dns update script usage
# # DNS update script vars
# variable "dns_domain_name" {
#   default = "__DNS_DOMAIN_NAME__"
# }

# variable "has_subdomain" {
#   default = "__HAS_SUBDOMAIN__"
# }

# variable "api_key" {
#   default = "__API_KEY__"
# }

# variable "api_secret" {
#   default = "__API_SECRET__"
# }
