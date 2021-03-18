# nexus helm chart

# https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
resource "kubernetes_namespace" "nexus" {
  metadata {
    name = "nexus"
  }
  timeouts {
    delete = "15m"
  }

  depends_on = [module.aks]
}

# https://www.terraform.io/docs/providers/helm/r/release.html
resource "helm_release" "nexus" {
  chart      = "sonatype-nexus"
  name       = "nexus"
  namespace  = kubernetes_namespace.nexus.metadata[0].name
  repository = "https://adamrushuk.github.io/charts/"
  version    = var.nexus_chart_version
  timeout    = 600
  atomic     = true

  values = [file("helm/nexus_values.yaml")]

  set {
    name  = "image.tag"
    value = var.nexus_image_tag
  }

  set {
    name  = "nexus.baseDomain"
    value = var.nexus_base_domain
  }

  set {
    name  = "nexus.certEmail"
    value = var.nexus_cert_email
  }

  set {
    name  = "ingress.enabled"
    value = var.nexus_ingress_enabled
  }

  set {
    name  = "ingress.letsencryptEnvironment"
    value = var.nexus_letsencrypt_environment
  }

  set {
    name  = "ingress.tls.secretName"
    value = var.nexus_tls_secret_name
  }

  depends_on = [helm_release.nginx]
}
