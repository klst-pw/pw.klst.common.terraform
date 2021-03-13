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
output "kubeconfig" {
  description = "Generated kubeconfig."
  sensitive   = true
  value       = try(module.k3s.kube_config, null)
}

output "service_account" {
  description = "Generated ServiceAccount for cluster bootstrap."
  sensitive   = true
  value = {
    host                   = try(module.k3s.kubernetes.api_endpoint, null)
    cluster_ca_certificate = try(module.k3s.kubernetes.cluster_ca_certificate, null)
    token                  = try(module.bootstrap_rbac.service_account_token, null)
  }
}

locals {
  pool_ids = transpose({
    for i in range(length(local.raw_nodes_list)) :
    i => [local.raw_nodes_list[i].pool_id]
  })
}

output "summary" {
  description = "Summary of the current project state."
  value = {
    vpc = {
      cidr         = var.network
      static_nodes = length(hcloud_server.control_planes)
    }
    ansible_inventory = {
      all = {
        hosts = merge({
          for i in range(length(hcloud_server.control_planes)) :
          hcloud_server.control_planes[i].name => {
            ansible_host : hcloud_server.control_planes[i].ipv4_address
            ansible_user : var.user

            kube_provider_name : "hetzner",
            kube_provider_tenant : var.name,
            kube_provider_id : hcloud_server.control_planes[i].id,
            kube_addresses : {
              public : [hcloud_server.control_planes[i].ipv4_address],
              private : [hcloud_server_network.control_planes[i].ip],
            }
          }
          }, {
          for i in range(length(hcloud_server.nodes)) :
          hcloud_server.nodes[i].name => {
            ansible_host : hcloud_server.nodes[i].ipv4_address
            ansible_user : var.user

            kube_provider_name : "hetzner",
            kube_provider_tenant : var.name,
            kube_provider_id : hcloud_server.nodes[i].id,
            kube_addresses : {
              public : [hcloud_server.nodes[i].ipv4_address],
              private : [hcloud_server_network.nodes[i].ip],
            }
          }
        })

        children = merge({
          control_planes = { for i in range(length(hcloud_server.control_planes)) : hcloud_server.control_planes[i].name => {} }
          nodes = {
            children = {
              for pool, ids in local.pool_ids :
              pool => { for id in ids : hcloud_server.nodes[id].name => {} }
            }
          }
        })
      }
    }
    kubernetes = try(module.k3s.summary, null)
  }
}
