# aad-pod-identity helm chart

# role assignment for aad-pod-identity
# https://azure.github.io/aad-pod-identity/docs/getting-started/role-assignment/#performing-role-assignments
resource "azurerm_role_assignment" "aks_mi_aks_node_rg_vm_contributor" {
  principal_id                     = module.aks.kubelet_identity[0].object_id
  role_definition_name             = "Virtual Machine Contributor"
  scope                            = data.azurerm_resource_group.aks_node_rg.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_mi_aks_node_rg_mi_operator" {
  principal_id                     = module.aks.kubelet_identity[0].object_id
  role_definition_name             = "Managed Identity Operator"
  scope                            = data.azurerm_resource_group.aks_node_rg.id
  skip_service_principal_aad_check = true
}

data "template_file" "azureIdentities" {
  template = file("${path.module}/files/azureIdentities.yaml.tpl")
  vars = {
    resourceID = azurerm_user_assigned_identity.velero[0].id
    clientID  = azurerm_user_assigned_identity.velero[0].client_id
  }
}

# https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
resource "kubernetes_namespace" "aad_pod_identity" {
  metadata {
    name = "aad-pod-identity"
  }
  timeouts {
    delete = "15m"
  }

  depends_on = [module.aks]
}

# https://www.terraform.io/docs/providers/helm/r/release.html
resource "helm_release" "aad_pod_identity" {
  chart      = "aad-pod-identity"
  name       = "aad-pod-identity"
  namespace  = "aad-pod-identity"
  repository = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
  version    = var.aad_pod_identity_chart_version

  values     = [
    file("helm/aad_pod_identity_values.yaml"),
    data.template_file.azureIdentities.rendered
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
  depends_on = [kubernetes_namespace.aad_pod_identity]
}
