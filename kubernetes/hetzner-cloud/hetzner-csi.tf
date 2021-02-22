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

resource "kubernetes_csi_driver" "csi-hetzner-cloud" {
  metadata {
    name = "csi.hetzner.cloud"

    labels = merge(
      local.common_labels,
      { "app.kubernetes.io/component" : "csi-driver" }
    )
  }

  spec {
    attach_required        = true
    pod_info_on_mount      = true
    volume_lifecycle_modes = ["Persistent"]
  }
}

resource "kubernetes_storage_class" "hetzner-cloud" {
  metadata {
    name = "hetzner.cloud"

    annotations = {
      "storageclass.kubernetes.io/is-default-class" : tostring(var.is_default_class)
    }
    labels = merge(
      local.common_labels,
      { "app.kubernetes.io/component" : "storage-class" }
    )
  }

  storage_provisioner    = "csi.hetzner.cloud"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
}
