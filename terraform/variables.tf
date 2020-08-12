# Variables


#region Versions
# version used for both main AKS API service, and default node pool
variable "kubernetes_version" {
  # lowest v1.15: 1.15.11
  # current default: 1.16.13
  # default = "1.15.11"
  default = "1.16.13"
}

# Helm charts
# Deprecated? https://hub.helm.sh/charts/stable/nginx-ingress
# new? https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/
variable "nginx_chart_version" {
  default = "1.40.3"
}

# https://hub.helm.sh/charts/jetstack/cert-manager
variable "cert_manager_chart_version" {
  default = "v0.15.2"
}

# https://github.com/vmware-tanzu/helm-charts/releases
variable "velero_chart_version" {
  default = "2.12.13"
}
#endregion Versions



# Common
variable "prefix" {
  default = "__PREFIX__"
}

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

variable "tags" {
  description = "A map of the tags to use on the resources"

  default = {
    Env    = "Dev"
    Owner  = "Adam Rush"
    Source = "terraform"
  }
}



# AKS
variable "azurerm_kubernetes_cluster_name" {
  default = "__AKS_CLUSTER_NAME__"
}

variable "aad_group_name" {
  description = "Name of the Azure AD group for cluster-admin access"
  type        = string
  default     = "AKS-Admins"
}

variable "sla_sku" {
  description = "Define the SLA under which the managed master control plane of AKS is running"
  type        = string
  default     = "Free"
}

variable "aks_dashboard_enabled" {
  description = "Should Kubernetes dashboard be enabled"
  default     = false
}

variable "aks_container_insights_enabled" {
  description = "Should Container Insights monitoring be enabled"
  default     = false
}


# TODO DELETE SECTION
# Service Principle for AKS
# variable "service_principal_client_id" {
#   default = "__ARM_CLIENT_ID__"
# }

# variable "service_principal_client_secret" {
#   default = "__ARM_CLIENT_SECRET__"
# }
# TODO DELETE SECTION


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
  # https://docs.microsoft.com/en-us/azure/virtual-machines/dv3-dsv3-series#dsv3-series
  default = "Standard_D2s_v3"
}

variable "agent_pool_profile_os_type" {
  default = "Linux"
}

variable "agent_pool_profile_disk_size_gb" {
  default = 30
}



# Velero
variable "velero_enabled" {
  description = "Should Velero be enabled"
  default     = true
}

variable "velero_resource_group_name" {
  default = "__VELERO_STORAGE_RG__"
}

variable "velero_storage_account_name" {
  default = "__VELERO_STORAGE_ACCOUNT__"
}

variable "velero_service_principle_name" {
  default = "sp_velero"
}

variable "velero_backup_retention" {
  # for testing, only retain for 2hrs
  default = "2h0m0s"
}

# https://crontab.guru/
variable "velero_backup_schedule" {
  description = "Velero backup schedule in cron format"
  # for testing, backup every hour"
  default = "0 */1 * * *"
}

variable "velero_backup_included_namespaces" {
  type = list(string)
  default = [
    "ingress"
  ]
}



# DNS
variable "dns_service_principle_name" {
  default = "sp_external_dns"
}

variable "dns_resource_group_name" {
  default = "__DNS_RG_NAME__"
}

variable "dns_zone_name" {
  default = "__ROOT_DOMAIN_NAME__"
}

# not currently used as zone defaults to these anyway
variable "dns_name_servers" {
  type = list(string)
  default = [
    "ns1-07.azure-dns.com.",
    "ns2-07.azure-dns.net.",
    "ns3-07.azure-dns.org.",
    "ns4-07.azure-dns.info."
  ]
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



# Function Apps
variable "func_app_sas_expires_in_hours" {
  # 2190h = 3 months
  default = "2190h"
}

variable "ifttt_webhook_key" {
  default = "__IFTTT_WEBHOOK_KEY__"
}
