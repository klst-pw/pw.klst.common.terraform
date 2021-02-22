#                                       __
#                                     /\\ \
#                                   /\\ \\ \\
#                                   \// // //
#                                     \//_/
#
#                             K L S T - P r o j e c t
#                                Terraform  Module
#
# ------------------------------------------------------------------------------

resource "helm_release" "external_dns" {
  name      = "external-dns"
  namespace = "kube-system"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  version    = var.external_dns_version

  values = [yamlencode(var.configuration)]

  set {
    name  = "replicas"
    value = 1
  }
  set {
    name  = "provider"
    value = var.dns_provider
  }
  set {
    name  = "metrics.enabled"
    value = true
  }
}

resource "null_resource" "is_ready" {
  depends_on = [helm_release.external_dns]
}