# aad-pod-identity helm chart

# role assignment for aad-pod-identity
# https://azure.github.io/aad-pod-identity/docs/getting-started/role-assignment/#performing-role-assignments
resource "azurerm_role_assignment" "aks_mi_aks_node_rg_vm_contributor" {
  count                            = var.velero_enabled ? 1 : 0
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "Virtual Machine Contributor"
  scope                            = data.azurerm_resource_group.aks_node_rg.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_mi_aks_node_rg_mi_operator" {
  count                            = var.velero_enabled ? 1 : 0
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "Managed Identity Operator"
  scope                            = data.azurerm_resource_group.aks_node_rg.id
  skip_service_principal_aad_check = true
}

# velero user MI in different RG, so assign role there too
resource "azurerm_role_assignment" "aks_mi_velero_rg_mi_operator" {
  count                            = var.velero_enabled ? 1 : 0
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "Managed Identity Operator"
  scope                            = azurerm_resource_group.velero[0].id
  skip_service_principal_aad_check = true
}

data "template_file" "azureIdentities" {
  count    = var.velero_enabled ? 1 : 0
  template = file("${path.module}/files/azureIdentities.yaml.tpl")
  vars = {
    resourceID = azurerm_user_assigned_identity.velero[0].id
    clientID  = azurerm_user_assigned_identity.velero[0].client_id
  }
}

# https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
resource "kubernetes_namespace" "aad_pod_identity" {
  count    = var.velero_enabled ? 1 : 0
  metadata {
    name = "aad-pod-identity"
  }
  timeouts {
    delete = "15m"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# https://www.terraform.io/docs/providers/helm/r/release.html
resource "helm_release" "aad_pod_identity" {
  count    = var.velero_enabled ? 1 : 0
  chart      = "aad-pod-identity"
  name       = "aad-pod-identity"
  namespace  = "aad-pod-identity"
  repository = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
  version    = var.aad_pod_identity_chart_version

  values     = [
    file("helm/aad_pod_identity_values.yaml"),
    data.template_file.azureIdentities[0].rendered
  ]

  set {
    name  = "installCRDs"
    value = "true"
  }

  # https://github.com/Azure/aad-pod-identity/wiki/Debugging#increasing-the-verbosity-of-the-logs
  set {
    name  = "mic.logVerbosity"
    value = 6
  }

  timeout    = 600
  depends_on = [kubernetes_namespace.aad_pod_identity[0]]
}
