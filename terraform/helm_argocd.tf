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

  set {
    name  = "server.ingress.hosts[0]"
    value = "argocd.${var.dns_zone_name}"
  }

  set {
    name  = "server.ingress.tls[0].hosts[0]"
    value = "argocd.${var.dns_zone_name}"
  }

  set {
    name  = "server.ingress.tls[0].secretName"
    value = "argocd-ingress-tls"
  }

  # Argo CD's externally facing base URL
  # used for logout destination and when configuring SSO
  set {
    name  = "server.config.url"
    value = "https://argocd.${var.dns_zone_name}"
  }
}
