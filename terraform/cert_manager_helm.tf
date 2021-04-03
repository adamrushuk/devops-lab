# cert-manager helm chart
#
# https://hub.helm.sh/charts/jetstack/cert-manager/
# https://cert-manager.io/docs/installation/kubernetes/#installing-with-helm

# https://www.terraform.io/docs/providers/helm/r/release.html
resource "helm_release" "cert_manager" {
  chart      = "cert-manager"
  name       = "cert-manager"
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  repository = "https://charts.jetstack.io"
  version    = var.cert_manager_chart_version
  timeout    = 600
  atomic     = true

  set {
    name  = "global.logLevel"
    value = "3"
  }

  set {
    name  = "installCRDs"
    value = "true"
  }
}
