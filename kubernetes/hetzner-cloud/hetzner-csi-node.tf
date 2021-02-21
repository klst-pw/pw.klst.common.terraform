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

resource "kubernetes_service_account" "csi_node" {
  metadata {
    name      = "csi-node"
    namespace = "kube-system"

    labels = merge(
      local.common_labels,
      { "app.kubernetes.io/component" : "rbac" }
    )
  }
}

resource "kubernetes_cluster_role" "system_csi_node" {
  metadata {
    name = "system:csi:node"

    labels = merge(
      local.common_labels,
      { "app.kubernetes.io/component" : "rbac" }
    )
  }

  # CSI node rules
  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["get", "list", "watch", "create", "update", "patch"]
  }
}

resource "kubernetes_cluster_role_binding" "system_csi_node" {
  metadata {
    name = "system:csi:node"

    labels = merge(
      local.common_labels,
      { "app.kubernetes.io/component" : "rbac" }
    )
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.csi_node.metadata[0].name
    namespace = kubernetes_service_account.csi_node.metadata[0].namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.system_csi_node.metadata[0].name
  }
}

locals {
  csi_node_version = "v1.8.1"
  csi_node_labels = {
    "app.kubernetes.io/name" : "hcloud-csi-node",
    "app.kubernetes.io/component" : "csi-node",
  }
}

resource "kubernetes_daemonset" "hcloud_csi_node" {
  metadata {
    name      = "hcloud-csi-node"
    namespace = "kube-system"

    labels = merge(local.common_labels, local.csi_node_labels)
  }

  spec {
    selector { match_labels = local.csi_node_labels }
    template {
      metadata {
        labels = local.csi_node_labels
      }

      spec {
        service_account_name = kubernetes_service_account.csi_node.metadata[0].name

        container {
          name  = "csi-node-driver-registrar"
          image = "quay.io/k8scsi/csi-node-driver-registrar:v1.3.0"

          args = [
            "--v=5",
            "--csi-address=/csi/csi.sock",
            "--kubelet-registration-path=/var/lib/kubelet/plugins/csi.hetzner.cloud/csi.sock"
          ]

          env {
            name = "KUBE_NODE_NAME"
            value_from {
              field_ref { field_path = "spec.nodeName" }
            }
          }

          volume_mount {
            name       = "plugin-dir"
            mount_path = "/csi"
          }
          volume_mount {
            name       = "registration-dir"
            mount_path = "/registration"
          }

          security_context {
            privileged = true
          }
        }

        container {
          name              = "hcloud-csi-driver"
          image             = "hetznercloud/hcloud-csi-driver:1.5.1"
          image_pull_policy = "Always"

          env {
            name  = "CSI_ENDPOINT"
            value = "unix:///csi/csi.sock"
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
            name              = "kubelet-dir"
            mount_path        = "/var/lib/kubelet"
            mount_propagation = "Bidirectional"
          }
          volume_mount {
            name       = "plugin-dir"
            mount_path = "/csi"
          }
          volume_mount {
            name       = "device-dir"
            mount_path = "/dev"
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
          args  = ["--csi-address=/csi/csi.sock"]

          volume_mount {
            name       = "plugin-dir"
            mount_path = "/csi"
          }
        }

        init_container {
          name  = "wait-controller"
          image = "busybox@sha256:56853b711255f4a0bc7c44d2158167f03f64ef75a22a0249a9fae4703ec10f61"
          args = [
            "sh",
            "-c",
            "echo waiting CSI controller && until timeout 2 sh -c \"wget -O- > /dev/null http://$${HCLOUD_CSI_CONTROLLER_METRICS_SERVICE_HOST}:$${HCLOUD_CSI_CONTROLLER_METRICS_SERVICE_PORT}\"; do echo -n .; sleep 2; done"
          ]
        }

        volume {
          name = "kubelet-dir"
          host_path {
            path = "/var/lib/kubelet"
            type = "Directory"
          }
        }
        volume {
          name = "plugin-dir"
          host_path {
            path = "/var/lib/kubelet/plugins/csi.hetzner.cloud"
            type = "DirectoryOrCreate"
          }
        }
        volume {
          name = "registration-dir"
          host_path {
            path = "/var/lib/kubelet/plugins_registry"
            type = "Directory"
          }
        }
        volume {
          name = "device-dir"
          host_path {
            path = "/dev"
            type = "Directory"
          }
        }

        toleration {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }
        toleration {
          effect   = "NoExecute"
          operator = "Exists"
        }
        toleration {
          effect   = "NoSchedule"
          operator = "Exists"
        }
      }
    }
  }
}

resource "kubernetes_service" "hcloud_csi_node_metrics" {
  metadata {
    name      = "hcloud-csi-node-metrics"
    namespace = "kube-system"

    labels = merge(
      local.common_labels,
      { "app.kubernetes.io/component" : "metrics-service" }
    )
  }

  spec {
    selector = local.csi_node_labels
    port {
      name        = "metrics"
      port        = 9189
      target_port = "metrics"
    }
  }
}