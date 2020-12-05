# kured helm chart
# https://docs.microsoft.com/en-us/azure/aks/node-updates-kured

# https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
resource "kubernetes_namespace" "kured" {
  metadata {
    name = "kured"
  }

  timeouts {
    delete = "15m"
  }

  depends_on = [module.aks]
}

# https://www.terraform.io/docs/providers/helm/r/release.html
resource "helm_release" "kured" {
  chart      = "kured"
  name       = "kured"
  namespace  = kubernetes_namespace.kured.metadata[0].name
  repository = "https://weaveworks.github.io/kured"
  version    = var.kured_chart_version
  timeout    = 600

  values = ["${file("helm/kured_values.yaml")}"]

  set {
    name  = "image.tag"
    value = var.kured_image_tag
  }

  # increase testing period frequency, when testing with "sudo touch /var/run/reboot-required"
  # set {
  #   name  = "configuration.period"
  #   value = "1m"
  # }
}
