# Variables


#region Versions
# version used for both main AKS API service, and default node pool
# https://github.com/Azure/AKS/releases
# az aks get-versions --location eastus --output table
variable "kubernetes_version" {
  default = "1.19.7"
}

# Helm charts
# Migrated to newer kubernetes nginx helm chart:
# https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx#migrating-from-stablenginx-ingress
#
# https://kubernetes.github.io/ingress-nginx/deploy/#using-helm
# https://github.com/kubernetes/ingress-nginx/releases
# https://github.com/kubernetes/ingress-nginx/blob/ingress-nginx-3.11.0/charts/ingress-nginx/Chart.yaml#L3
#
# helm repo update
# helm search repo ingress-nginx/ingress-nginx
# * also update terraform/helm/nginx_values.yaml
variable "nginx_chart_version" {
  default = "3.29.0"
}

# https://hub.helm.sh/charts/jetstack/cert-manager
# helm search repo jetstack/cert-manager
variable "cert_manager_chart_version" {
  default = "v1.3.1"
}

# https://github.com/vmware-tanzu/helm-charts/releases
# helm search repo vmware-tanzu/velero
# * also update terraform/helm/velero_values.yaml
variable "velero_chart_version" {
  default = "2.17.2"
}

# https://hub.docker.com/r/velero/velero/tags
variable "velero_image_tag" {
  default = "v1.6.0"
}

# https://hub.docker.com/r/sonatype/nexus3/tags
variable "nexus_image_tag" {
  default = "3.30.0"
}

# https://github.com/adamrushuk/charts/releases
# helm search repo adamrushuk/sonatype-nexus
variable "nexus_chart_version" {
  default = "0.2.8"
}

# https://github.com/SparebankenVest/azure-key-vault-to-kubernetes
# https://github.com/SparebankenVest/public-helm-charts/releases
# https://github.com/SparebankenVest/helm-charts/tree/gh-pages/akv2k8s
# https://github.com/SparebankenVest/public-helm-charts/blob/master/stable/akv2k8s/Chart.yaml#L5
# helm search repo spv-charts/akv2k8s
variable "akv2k8s_chart_version" {
  default = "2.0.10"
}

# https://github.com/Azure/aad-pod-identity/blob/master/charts/aad-pod-identity/Chart.yaml#L4
# helm search repo aad-pod-identity/aad-pod-identity
variable "aad_pod_identity_chart_version" {
  default = "4.0.0"
}

# https://bitnami.com/stack/external-dns/helm
# https://github.com/bitnami/charts/blob/master/bitnami/external-dns/Chart.yaml#L21
# helm search repo bitnami/external-dns
variable "external_dns_chart_version" {
  default = "4.10.0"
}

# https://github.com/weaveworks/kured/tree/master/charts/kured
# helm search repo kured/kured
variable "kured_chart_version" {
  default = "2.4.2"
}

# https://github.com/weaveworks/kured#kubernetes--os-compatibility
variable "kured_image_tag" {
  default = "1.6.1"
}


# argo cd
# https://github.com/argoproj/argo-helm/blob/master/charts/argo-cd/Chart.yaml#L5
# helm search repo argo/argo-cd
variable "argocd_chart_version" {
  default = "3.1.1"
}

# https://hub.docker.com/r/argoproj/argocd/tags
variable "argocd_image_tag" {
  default = "v2.0.1"
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

variable "aks_admins_aad_group_name" {
  description = "Name an existing Azure AD group for AKS admins"
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
  default = null
}

variable "agent_pool_node_max_count" {
  default = null
}

variable "agent_pool_profile_name" {
  default = "default"
}

variable "agent_pool_profile_vm_size" {
  # https://azureprice.net/?region=ukwest&currency=GBP
  # Standard_D2s_v3 - £0.086455 per hour
  # 2 x CPU, 8GB RAM, 4 x Data Disks
  # https://docs.microsoft.com/en-us/azure/virtual-machines/dv3-dsv3-series#dsv3-series

  # Standard_DS2_v2 - £0.130429 per hour
  # 2 x CPU, 7GB RAM, 8 x Data Disks
  # https://docs.microsoft.com/en-us/azure/virtual-machines/dv2-dsv2-series?toc=/azure/virtual-machines/linux/toc.json&bc=/azure/virtual-machines/linux/breadcrumb/toc.json#dsv2-series

  # ! Standard_B4ms can cause performance issues
  # Standard_B4ms   - £0.140863 per hour
  # 4 x CPU, 16GB RAM, 8 x Data Disks

  # Standard_D4s_v3 - £0.172911 per hour
  # 4 x CPU, 16GB RAM, 8 x Data Disks

  # Standard_F8s_v2 - £0.301104 per hour
  # 8 x CPU, 16GB RAM, 16 x Data Disks
  default = "Standard_D4s_v3"
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
variable "nexus_cert_sync_yaml_path" {
  default = "files/nexus-akvs-certificate-sync.yaml"
}



# argo cd
variable "argocd_admins_aad_group_name" {
  default = "ArgoCD_Admins"
}

variable "argocd_admin_password" {
  default = "__ARGOCD_ADMIN_PASSWORD__"
}

variable "argocd_cert_sync_yaml_path" {
  default = "files/argocd-akvs-certificate-sync.yaml"
}

variable "argocd_fqdn" {
  default = "__ARGOCD_FQDN__"
}

variable "helm_chart_repo_deploy_private_key" {
  default = <<-EOT
__HELM_CHART_REPO_DEPLOY_PRIVATE_KEY__
EOT
}

variable "argocd_apps_path" {
  default = "files/argocd-apps.yaml"
}

variable "argocd_app_reg_name" {
  default = "sp_argocd_oidc"
}

variable "argocd_cm_yaml_path" {
  default = "files/argocd-cm-patch.tmpl.yaml"
}

variable "argocd_secret_yaml_path" {
  default = "files/argocd-secret-patch.tmpl.yaml"
}

variable "argocd_rbac_cm_yaml_path" {
  default = "files/argocd-rbac-cm-patch.tmpl.yaml"
}



# gitlab
variable "gitlab_cert_sync_yaml_path" {
  default = "files/gitlab-akvs-certificate-sync.yaml"
}
