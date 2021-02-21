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

locals {
  common_labels = {
    "app.kubernetes.io/part-of" : "hetzner-cloud",
    "app.kubernetes.io/managed-by" : "terraform",
  }
}

resource "kubernetes_secret" "hcloud" {
  metadata {
    name      = "hcloud"
    namespace = "kube-system"

    labels = merge(
      local.common_labels,
      { "app.kubernetes.io/component" : "secrets" }
    )
  }

  type = "Opaque"
  data = {
    "token" = var.hcloud_token
  }
}

resource "null_resource" "is_ready" {
  depends_on = [
    kubernetes_secret.hcloud,
    kubernetes_deployment.hcloud_cloud_controller_manager,
    kubernetes_stateful_set.hcloud_csi_controller,
    kubernetes_daemonset.hcloud_csi_node
  ]
}