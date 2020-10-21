# aad-pod-identity helm chart

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
resource "helm_release" "aad_pod_identity" {
  chart      = "aad-pod-identity"
  name       = "aad-pod-identity"
  namespace  = "aad-pod-identity"
  repository = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
  version    = var.aad_pod_identity_chart_version
  values     = ["${file("helm/aad_pod_identity_values.yaml")}"]

  set {
    name  = "installCRDs"
    value = "true"
  }

  timeout    = 600
  depends_on = [kubernetes_namespace.aad_pod_identity]
}
