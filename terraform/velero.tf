# Velero

# Prereqs
# https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure/blob/master/README.md#Create-Azure-storage-account-and-blob-container
resource "azurerm_resource_group" "velero" {
  name     = var.velero_resource_group_name
  location = var.location
  tags     = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_storage_account" "velero" {
  name                      = var.velero_storage_account_name
  resource_group_name       = azurerm_resource_group.velero.name
  location                  = azurerm_resource_group.velero.location
  account_kind              = "BlobStorage"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_storage_container" "velero" {
  name                  = "velero"
  storage_account_name  = azurerm_storage_account.velero.name
  container_access_type = "private"
}


# Kubernetes
resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
  }
  timeouts {
    delete = "10m"
  }
}

resource "kubernetes_secret" "velero_credentials" {
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
    AZURE_TENANT_ID=${data.azurerm_subscription.current.tenant_id}
    AZURE_CLIENT_ID=${azuread_service_principal.velero_sp.application_id}
    AZURE_CLIENT_SECRET=${random_string.velero_sp.result}
    AZURE_RESOURCE_GROUP=${azurerm_kubernetes_cluster.aks.node_resource_group}
    AZURE_CLOUD_NAME=AzurePublicCloud
    EOT
  }

  type       = "Opaque"
  depends_on = [kubernetes_namespace.velero]
}

# Manually test new values:
# helm upgrade \
#     velero vmware-tanzu/velero \
#     --install --atomic \
#     --namespace velero \
#     --reuse-values \
#     -f terraform/helm/velero_values.yaml

resource "helm_release" "velero" {
  atomic     = true
  chart      = "velero"
  name       = "velero"
  namespace  = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  values     = ["${file("helm/velero_values.yaml")}"]
  version    = var.velero_chart_version
  set {
    name  = "configuration.backupStorageLocation.config.resourceGroup"
    value = azurerm_resource_group.velero.name
  }
  set {
    name  = "configuration.backupStorageLocation.config.storageAccount"
    value = azurerm_storage_account.velero.name
  }
  set {
    name  = "configuration.volumeSnapshotLocation.config.resourceGroup"
    value = azurerm_resource_group.velero.name
  }
  set_string {
    name  = "schedules.fullbackup.schedule"
    value = var.velero_backup_schedule
  }
  set_string {
    name  = "schedules.fullbackup.template.ttl"
    value = var.velero_backup_retention
  }
  set {
    name  = "schedules.fullbackup.excludedNamespaces"
    value = "velero"
  }
  # set {
  #   name  = "credentials.secretContents.cloud"
  #   value = var.credentials_velero
  # }
  # set {
  #   name  = "configuration.logLevel"
  #   value = "debug"
  # }
  timeout    = 600
  depends_on = [kubernetes_namespace.velero]
}
