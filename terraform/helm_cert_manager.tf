# cert-manager helm chart
#
# https://hub.helm.sh/charts/jetstack/cert-manager/
# https://cert-manager.io/docs/installation/kubernetes/#installing-with-helm

# https://www.terraform.io/docs/providers/helm/r/release.html
resource "helm_release" "cert_manager" {
  chart      = "cert-manager"
  name       = "cert-manager"
  namespace  = "ingress"
  repository = data.helm_repository.jetstack.metadata[0].name
  version    = "v0.15.0-alpha.0"
  set {
    name  = "global.logLevel"
    value = "3"
  }
  set {
    name  = "installCRDs"
    value = "true"
  }
}
