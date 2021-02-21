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

resource "kubernetes_service_account" "csi_controller" {
  metadata {
    name      = "csi-controller"
    namespace = "kube-system"

    labels = merge(
      local.common_labels,
      { "app.kubernetes.io/component" : "rbac" }
    )
  }
}

resource "kubernetes_cluster_role" "system_csi_controller" {
  metadata {
    name = "system:csi:controller"

    labels = merge(
      local.common_labels,
      { "app.kubernetes.io/component" : "rbac" }
    )
  }

  # CSI attacher rules
  rule {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs      = ["get", "list", "watch", "update", "patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["csi.storage.k8s.io"]
    resources  = ["csinodeinfos"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["csinodes"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["volumeattachments"]
    verbs      = ["get", "list", "watch", "update", "patch"]
  }

  # CSI provisioner rules
  # rule {
  #   api_groups = [""]
  #   resources  = ["secrets"]
  #   verbs      = ["get", "list"]
  # }
  rule {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs      = ["get", "list", "watch", "create", "delete", "patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["persistentvolumeclaims", "persistentvolumeclaims/status"]
    verbs      = ["get", "list", "watch", "update", "patch"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["list", "watch", "create", "update", "patch"]
  }
  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshots"]
    verbs      = ["get", "list"]
  }
  rule {
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotcontents"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "system_csi_controller" {
  metadata {
    name = "system:csi:controller"

    labels = merge(
      local.common_labels,
      { "app.kubernetes.io/component" : "rbac" }
    )
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.csi_controller.metadata[0].name
    namespace = kubernetes_service_account.csi_controller.metadata[0].namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.system_csi_controller.metadata[0].name
  }
}

locals {
  csi_controller_version = "v1.8.1"
  csi_controller_labels = {
    "app.kubernetes.io/name" : "hcloud-csi-controller",
    "app.kubernetes.io/component" : "csi-controller",
  }
}

resource "kubernetes_stateful_set" "hcloud_csi_controller" {
  metadata {
    name      = "hcloud-csi-controller"
    namespace = "kube-system"

    labels = merge(local.common_labels, local.csi_controller_labels)
  }

  spec {
    replicas     = 1
    service_name = "hcloud-csi-controller"

    selector { match_labels = local.csi_controller_labels }
    template {
      metadata {
        labels = local.csi_controller_labels
      }

      spec {
        service_account_name = kubernetes_service_account.csi_controller.metadata[0].name

        container {
          name  = "csi-attacher"
          image = "quay.io/k8scsi/csi-attacher:v2.2.0"
          args = [
            "--csi-address=/var/lib/csi/sockets/pluginproxy/csi.sock",
            "--v=5"
          ]

          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }

          security_context {
            privileged                 = true
            allow_privilege_escalation = true

            capabilities {
              add = ["SYS_ADMIN"]
            }
          }
        }

        container {
          name  = "csi-resizer"
          image = "quay.io/k8scsi/csi-resizer:v0.3.0"
          args = [
            "--csi-address=/var/lib/csi/sockets/pluginproxy/csi.sock",
            "--v=5"
          ]

          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }

          security_context {
            privileged                 = true
            allow_privilege_escalation = true

            capabilities {
              add = ["SYS_ADMIN"]
            }
          }
        }

        container {
          name  = "csi-provisioner"
          image = "quay.io/k8scsi/csi-provisioner:v1.6.0"
          args = [
            "--provisioner=csi.hetzner.cloud",
            "--csi-address=/var/lib/csi/sockets/pluginproxy/csi.sock",
            "--feature-gates=Topology=true",
            "--v=5"
          ]

          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }

          security_context {
            privileged                 = true
            allow_privilege_escalation = true

            capabilities {
              add = ["SYS_ADMIN"]
            }
          }
        }

        container {
          name              = "hcloud-csi-driver"
          image             = "hetznercloud/hcloud-csi-driver:1.5.1"
          image_pull_policy = "Always"

          env {
            name  = "CSI_ENDPOINT"
            value = "unix:///var/lib/csi/sockets/pluginproxy/csi.sock"
          }
          env {
            name  = "METRICS_ENDPOINT"
            value = "0.0.0.0:9189"
          }
          env {
            name = "KUBE_NODE_NAME"
            value_from {
              field_ref { field_path = "spec.nodeName" }
            }
          }
          env {
            name = "HCLOUD_TOKEN"
            value_from {
              secret_key_ref {
                key  = "token"
                name = kubernetes_secret.hcloud.metadata[0].name
              }
            }
          }

          port {
            name           = "metrics"
            container_port = 9189
          }
          port {
            name           = "healthz"
            container_port = 9808
          }

          liveness_probe {
            failure_threshold = 5
            http_get {
              path = "/healthz"
              port = "healthz"
            }
            initial_delay_seconds = 10
            timeout_seconds       = 3
            period_seconds        = 2
          }

          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }

          security_context {
            privileged                 = true
            allow_privilege_escalation = true

            capabilities {
              add = ["SYS_ADMIN"]
            }
          }
        }

        container {
          name  = "liveness-probe"
          image = "quay.io/k8scsi/livenessprobe:v1.1.0"
          args  = ["--csi-address=/var/lib/csi/sockets/pluginproxy/csi.sock"]

          volume_mount {
            name       = "socket-dir"
            mount_path = "/var/lib/csi/sockets/pluginproxy/"
          }
        }

        volume {
          name = "socket-dir"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "hcloud_csi_controller_metrics" {
  metadata {
    name      = "hcloud-csi-controller-metrics"
    namespace = "kube-system"

    labels = merge(
      local.common_labels,
      { "app.kubernetes.io/component" : "metrics-service" }
    )
  }

  spec {
    selector = local.csi_controller_labels
    port {
      name        = "metrics"
      port        = 9189
      target_port = "metrics"
    }
  }
}