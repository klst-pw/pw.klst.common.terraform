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
  // TODO(ani): replace condition with defaults function when available (https://www.terraform.io/docs/configuration/functions/defaults.html)
  control_planes_k3s_args    = var.control_planes.k3s_args == null ? [] : var.control_planes.k3s_args
  control_planes_annotations = var.control_planes.annotations == null ? {} : var.control_planes.annotations
  control_planes_labels      = var.control_planes.labels == null ? {} : var.control_planes.labels
  control_planes_taints      = var.control_planes.taints == null ? {} : var.control_planes.taints

  control_plane_nodes = [
    for i in range(length(hcloud_server.control_planes)) :
    {
      __hash = md5(hcloud_server.control_planes[i].name)

      name = hcloud_rdns.control_planes[i].dns_ptr
      ip   = hcloud_server_network.control_planes[i].ip

      flags = local.control_planes_k3s_args

      annotations = local.control_planes_annotations
      labels      = merge(local.control_planes_labels, local.kubernetes_labels)
      taints      = local.control_planes_taints

      connection = {
        host = i == 0 ? hcloud_server.control_planes[i].ipv4_address : hcloud_server_network.control_planes[i].ip
        user = var.user

        bastion_host = i == 0 ? null : hcloud_server.control_planes[0].ipv4_address
        bastion_user = i == 0 ? null : var.user
      }
    }
  ]
}

locals {
  // TODO(ani): replace condition with defaults function when available (https://www.terraform.io/docs/configuration/functions/defaults.html)
  raw_nodes_list = flatten([for pool, definition in var.node_pools :
    [for _ in range(definition.count) :
      {
        pool_id : pool,

        flags = definition.k3s_args == null ? [] : definition.k3s_args

        annotations = definition.annotations == null ? {} : definition.annotations
        labels = merge(definition.labels == null ? {} : definition.labels, {
          "node-role.kubernetes.io/agent"            = "true"
          "node-role.kubernetes.io/nodepool-${pool}" = "true"
        })
        taints = definition.taints == null ? {} : definition.taints
      }
  ]])

  nodes_list = [
    for i in range(length(hcloud_server.nodes)) :
    {
      __hash = md5(hcloud_server.nodes[i].name)

      name = hcloud_rdns.nodes[i].dns_ptr
      ip   = hcloud_server_network.nodes[i].ip

      flags = local.raw_nodes_list[i].flags

      annotations = local.raw_nodes_list[i].annotations
      labels      = merge(local.raw_nodes_list[i].labels, local.kubernetes_labels)
      taints      = local.raw_nodes_list[i].taints

      connection = {
        host = hcloud_server_network.nodes[i].ip
        user = var.user

        bastion_host = hcloud_server.control_planes[0].ipv4_address
        bastion_user = var.user
      }
    }
  ]
}

module "k3s" {
  source  = "xunleii/k3s/module"
  version = "~>2.2.0"

  k3s_version  = var.k3s_version
  global_flags = var.k3s_args

  drain_timeout = var.drain_timeout

  servers = {
    for node in local.control_plane_nodes :
    node.__hash => node
  }

  agents = {
    for node in local.nodes_list :
    node.__hash => node
  }
}
