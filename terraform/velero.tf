# Velero

# Prereqs
# https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure/blob/master/README.md#Create-Azure-storage-account-and-blob-container

resource "azurerm_storage_account" "velero" {
  count                     = var.velero_enabled ? 1 : 0
  name                      = var.velero_storage_account_name
  resource_group_name       = azurerm_resource_group.aks.name
  location                  = azurerm_resource_group.aks.location
  account_kind              = "BlobStorage"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  tags                      = var.tags
}

resource "azurerm_storage_container" "velero" {
  count                 = var.velero_enabled ? 1 : 0
  name                  = "velero"
  storage_account_name  = azurerm_storage_account.velero[0].name
  container_access_type = "private"
}


# Kubernetes
resource "kubernetes_namespace" "velero" {
  count = var.velero_enabled ? 1 : 0
  metadata {
    name = "velero"
  }
  timeouts {
    delete = "15m"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "kubernetes_secret" "velero_credentials" {
  count = var.velero_enabled ? 1 : 0
  metadata {
    name      = "velero-credentials"
    namespace = "velero"

    labels = {
      component = "velero"
    }
  }

  data = {
    cloud = <<EOT
AZURE_SUBSCRIPTION_ID=${data.azurerm_subscription.current.subscription_id}
AZURE_RESOURCE_GROUP=${azurerm_kubernetes_cluster.aks.node_resource_group}
AZURE_CLOUD_NAME=AzurePublicCloud
EOT
  }

  type       = "Opaque"
  depends_on = [kubernetes_namespace.velero]
}

resource "helm_release" "velero" {
  count      = var.velero_enabled ? 1 : 0
  chart      = "velero"
  name       = "velero"
  namespace  = kubernetes_namespace.velero[0].metadata[0].name
  repository = "https://vmware-tanzu.github.io/helm-charts"
  version    = var.velero_chart_version
  timeout    = 600
  atomic     = true
  values     = [file("helm/velero_values.yaml")]

  set {
    name  = "image.tag"
    value = var.velero_image_tag
  }

  set {
    name  = "configuration.backupStorageLocation[0].config.resourceGroup"
    value = azurerm_resource_group.aks.name
  }

  set {
    name  = "configuration.backupStorageLocation[0].config.storageAccount"
    value = azurerm_storage_account.velero[0].name
  }

  set {
    name  = "configuration.volumeSnapshotLocation[0].config.resourceGroup"
    value = azurerm_resource_group.aks.name
  }

  set {
    name  = "schedules.fullbackup.schedule"
    value = var.velero_backup_schedule
  }

  set {
    name  = "schedules.fullbackup.template.ttl"
    value = var.velero_backup_retention
  }

  set {
    name  = "schedules.fullbackup.template.storageLocation"
    value = "default"
  }

  # set {
  #   name  = "schedules.fullbackup.template.excludedNamespaces"
  #   value = "velero"
  # }

  # use join when setting a list:
  # https://github.com/hashicorp/terraform-provider-helm/issues/92#issuecomment-407807183
  set {
    name  = "schedules.fullbackup.template.includedNamespaces"
    value = "{${join(",", var.velero_backup_included_namespaces)}}"
  }

  # https://github.com/vmware-tanzu/helm-charts/blob/velero-2.13.3/charts/velero/values.yaml#L27
  set {
    name  = "podLabels.aadpodidbinding"
    value = "velero"
  }

  # set {
  #   name  = "configuration.logLevel"
  #   value = "debug"
  # }
}
