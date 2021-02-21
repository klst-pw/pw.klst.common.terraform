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

resource "helm_release" "nginx_ingress" {
  name      = "nginx-ingress"
  namespace = "kube-ingress"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  version    = var.ingress_version

  set {
    name  = "ingressClass"
    value = "nginx-global"
  }
  set {
    name  = "publishService.enabled"
    value = true
  }

  set {
    name  = "fullnameOverride"
    value = "nginx-ingress"
  }

  create_namespace = true
}

resource "null_resource" "is_ready" {
  depends_on = [helm_release.nginx_ingress]
}