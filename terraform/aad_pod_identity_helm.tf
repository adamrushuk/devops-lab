# aad-pod-identity helm chart

# role assignment for aad-pod-identity
# https://azure.github.io/aad-pod-identity/docs/getting-started/role-assignment/#performing-role-assignments
resource "azurerm_role_assignment" "aks_mi_aks_node_rg_vm_contributor" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "Virtual Machine Contributor"
  scope                            = data.azurerm_resource_group.aks_node_rg.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_mi_aks_node_rg_mi_operator" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "Managed Identity Operator"
  scope                            = data.azurerm_resource_group.aks_node_rg.id
  skip_service_principal_aad_check = true
}

locals {
  azureIdentities = templatefile("${path.module}/files/azureIdentities.yaml.tpl", {
    resourceID = azurerm_user_assigned_identity.velero[0].id
    clientID   = azurerm_user_assigned_identity.velero[0].client_id
  })
}

# https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
resource "kubernetes_namespace" "aad_pod_identity" {
  metadata {
    name = "aad-pod-identity"
  }
  timeouts {
    delete = "15m"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# https://www.terraform.io/docs/providers/helm/r/release.html
resource "helm_release_v2" "aad_pod_identity" {
  chart      = "aad-pod-identity"
  name       = "aad-pod-identity"
  namespace  = kubernetes_namespace.aad_pod_identity.metadata[0].name
  repository = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
  version    = var.aad_pod_identity_chart_version
  timeout    = 600
  atomic     = true

  values = [
    # see default values: /helm/aad_pod_identity_default_values.yaml
    file("helm/aad_pod_identity_values.yaml"),
    local.azureIdentities
  ]

  set = [
    {
      name  = "nmi.allowNetworkPluginKubenet"
      value = "false"
      type  = "string"
    },
    {
      name  = "mic.logVerbosity"
      value = 6
      type  = "int"
    }
  ]
}
