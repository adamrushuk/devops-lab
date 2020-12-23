# argocd helm chart
# https://argoproj.github.io/argo-cd/

# https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  timeouts {
    delete = "15m"
  }

  depends_on = [module.aks]
}

# https://www.terraform.io/docs/providers/helm/r/release.html
resource "helm_release" "argocd" {
  chart      = "argo-cd"
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  version    = var.argocd_chart_version
  timeout    = 600
  values     = ["${file("${path.module}/files/argocd-values.yaml")}"]

  set {
    name  = "global.image.tag"
    value = var.argocd_image_tag
  }

  # TODO: test this works
  # argocd.thehypepipe.co.uk
  # ref:
  # - https://www.xspdf.com/resolution/53846273.html
  # - https://helm.sh/docs/chart_best_practices/values/
  # - https://helm.sh/docs/intro/using_helm/#the-format-and-limitations-of---set
  set {
    name  = "server.ingress.hosts[0]"
    value = "argocd.${var.dns_zone_name}"
  }

  set {
    name  = "server.ingress.tls[0].hosts[0]"
    value = "argocd.${local.dns_zone_name}"
  }

  set {
    name  = "server.ingress.tls[0].secretName"
    value = "argocd-ingress-tls"
  }
}
