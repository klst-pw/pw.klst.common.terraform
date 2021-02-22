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

resource "kubernetes_service_account" "cloud_controller" {
  metadata {
    name      = "cloud-controller"
    namespace = "kube-system"

    labels = merge(
      local.common_labels,
      { "app.kubernetes.io/component" : "rbac" }
    )
  }
}

resource "kubernetes_cluster_role" "system_controller_cloud_controller" {
  metadata {
    name = "system:controller:cloud-controller"

    labels = merge(
      local.common_labels,
      { "app.kubernetes.io/component" : "rbac" }
    )
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes", "nodes/status", "services/status"]
    verbs      = ["get", "list", "watch", "update", "patch"]
  }
  rule {
    api_groups = [""]
    # resources  = ["configmaps", "services"]
    resources = ["services"]
    verbs     = ["get", "list", "watch"]
  }
  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["extension-apiserver-authentication"]
    verbs          = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "system_controller_cloud_controller" {
  metadata {
    name = "system:controller:cloud-controller"

    labels = merge(
      local.common_labels,
      { "app.kubernetes.io/component" : "rbac" }
    )
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cloud_controller.metadata[0].name
    namespace = kubernetes_service_account.cloud_controller.metadata[0].namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.system_controller_cloud_controller.metadata[0].name
  }
}

locals {
  ccm_version = "v1.8.1"
  ccm_labels = {
    "app.kubernetes.io/name" : "hcloud-cloud-controller-manager",
    "app.kubernetes.io/component" : "cloud-controller-manager",
  }
}

resource "kubernetes_deployment" "hcloud_cloud_controller_manager" {
  metadata {
    name      = "hcloud-cloud-controller-manager"
    namespace = "kube-system"

    labels = merge(local.common_labels, local.ccm_labels)
  }

  spec {
    replicas = 1

    selector { match_labels = local.ccm_labels }
    template {
      metadata {
        annotations = { "scheduler.alpha.kubernetes.io/critical-pod" : "" }
        labels      = local.ccm_labels
      }

      spec {
        service_account_name = kubernetes_service_account.cloud_controller.metadata[0].name
        dns_policy           = "Default"

        container {
          name  = "hcloud-cloud-controller-manager"
          image = "hetznercloud/hcloud-cloud-controller-manager:${local.ccm_version}"

          command = [
            "/bin/hcloud-cloud-controller-manager",
            "--cloud-provider=hcloud",
            "--leader-elect=false",
            "--allow-untagged-cloud",
            "--allocate-node-cidrs=true",
            "--cluster-cidr=${var.hcloud_network.cidr}",
          ]

          env {
            name = "NODE_NAME"
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
          env {
            name  = "HCLOUD_NETWORK"
            value = var.hcloud_network.name
          }

          resources {
            requests = { "cpu" : "50m", "memory" : "50Mi" }
            limits   = { "cpu" : "200m", "memory" : "50Mi" }
          }
        }

        toleration {
          effect = "NoSchedule"
          key    = "node.cloudprovider.kubernetes.io/uninitialized"
          value  = "true"
        }
        toleration {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }
        toleration {
          effect   = "NoSchedule"
          key      = "node-role.kubernetes.io/master"
          operator = "Equal"
        }
      }
    }
  }
}