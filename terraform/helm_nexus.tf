# nexus helm chart

# https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
resource "kubernetes_namespace" "nexus" {
  metadata {
    name = "nexus"
  }
  timeouts {
    delete = "15m"
  }
}

# https://www.terraform.io/docs/providers/helm/r/release.html
resource "helm_release" "nexus" {
  chart      = "sonatype-nexus"
  name       = "nexus"
  namespace  = "nexus"
  repository = "https://adamrushuk.github.io/charts/"
  version    = var.nexus_chart_version

  # not using static values file, as using GH workflow vars
  # values     = ["${file("helm/nexus_values.yaml")}"]

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

  timeout    = 600
  depends_on = [helm_release.nginx, kubernetes_namespace.nexus]
}
