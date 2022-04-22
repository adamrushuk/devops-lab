# gitlab helm chart

# https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
resource "kubernetes_namespace" "gitlab" {
  metadata {
    name = "gitlab"
  }

  timeouts {
    delete = "15m"
  }

  depends_on = [module.aks]
}

# https://www.terraform.io/docs/provisioners/local-exec.html
resource "null_resource" "gitlab_cert_sync" {
  triggers = {
    # always_run = "${timestamp()}"
    cert_sync_yaml_contents = filemd5(var.gitlab_cert_sync_yaml_path)
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = var.aks_config_path
    }
    command = <<EOT
      kubectl apply -f ${var.gitlab_cert_sync_yaml_path}
    EOT
  }

  depends_on = [
    local_sensitive_file.kubeconfig,
    helm_release.akv2k8s,
    kubernetes_namespace.gitlab
  ]
}
