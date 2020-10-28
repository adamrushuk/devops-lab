# Variables


#region Versions
# version used for both main AKS API service, and default node pool
# https://github.com/Azure/AKS/releases
# az aks get-versions --location uksouth --output table
variable "kubernetes_version" {
  default = "1.16.15"
}

# Helm charts
# Migrated to newer kubernetes nginx helm chart:
# https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx#migrating-from-stablenginx-ingress
#
# https://kubernetes.github.io/ingress-nginx/deploy/#using-helm
# https://github.com/kubernetes/ingress-nginx/releases
# https://github.com/kubernetes/ingress-nginx/blob/master/charts/ingress-nginx/Chart.yaml#L3
variable "nginx_chart_version" {
  default = "3.4.0"
}

# https://hub.helm.sh/charts/jetstack/cert-manager
variable "cert_manager_chart_version" {
  default = "v1.0.3"
}

# https://github.com/vmware-tanzu/helm-charts/releases
variable "velero_chart_version" {
  default = "2.13.6"
}

# https://hub.docker.com/r/sonatype/nexus3/tags
variable "nexus_image_tag" {
  default = "3.28.1"
}

# https://github.com/adamrushuk/charts/releases
variable "nexus_chart_version" {
  default = "0.2.7"
}

# https://github.com/SparebankenVest/public-helm-charts/releases
# https://github.com/SparebankenVest/helm-charts/tree/gh-pages/akv2k8s
# https://github.com/SparebankenVest/public-helm-charts/blob/master/stable/akv2k8s/Chart.yaml#L5
variable "akv2k8s_chart_version" {
  default = "1.1.25"
}

# https://github.com/Azure/aad-pod-identity/blob/master/charts/aad-pod-identity/Chart.yaml#L4
variable "aad_pod_identity_chart_version" {
  default = "2.0.2"
}

# https://github.com/bitnami/charts/tree/master/bitnami/external-dns
# https://bitnami.com/stack/external-dns/helm
variable "external_dns_chart_version" {
  default = "3.4.9"
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

variable "key_vault_name" {
  default = "__KEY_VAULT_NAME__"
}

variable "key_vault_resource_group_name" {
  default = "__KEY_VAULT_RESOURCE_GROUP_NAME__"
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

variable "aks_container_insights_enabled" {
  description = "Should Container Insights monitoring be enabled"
  default     = false
}

variable "aks_config_path" {
  default = "./azurek8s_config"
}



# Agent Pool
variable "agent_pool_node_count" {
  default = 1
}

variable "agent_pool_enable_auto_scaling" {
  default = false
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
  default     = "__VELERO_ENABLED__"
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
    "nexus"
  ]
}



# DNS
variable "dns_resource_group_name" {
  default = "__DNS_RG_NAME__"
}

variable "dns_zone_name" {
  default = "__ROOT_DOMAIN_NAME__"
}

variable "azureidentity_external_dns_yaml_path" {
  default = "files/azureIdentity-external-dns.yaml.tpl"
}



# Function Apps
variable "func_app_sas_expires_in_hours" {
  # 2190h = 3 months
  default = "2190h"
}

variable "ifttt_webhook_key" {
  default = "__IFTTT_WEBHOOK_KEY__"
}



# Nexus
variable "nexus_base_domain" {
  default = "__ROOT_DOMAIN_NAME__"
}

variable "nexus_cert_email" {
  default = "__EMAIL_ADDRESS__"
}

variable "nexus_ingress_enabled" {
  default = "__ENABLE_TLS_INGRESS__"
}

variable "nexus_letsencrypt_environment" {
  default = "__CERT_API_ENVIRONMENT__"
}

variable "nexus_tls_secret_name" {
  default = "__K8S_TLS_SECRET_NAME__"
}



# akv2k8s
variable "akv2k8s_yaml_path" {
  default = "files/AzureKeyVaultSecret.yaml"
}

variable "akv2k8s_exception_yaml_path" {
  default = "files/akv2k8s-exception.yaml"
}

variable "cert_sync_yaml_path" {
  default = "files/akvs-certificate-sync.yaml"
}
