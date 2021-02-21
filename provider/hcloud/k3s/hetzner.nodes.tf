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
  nodes_servers = flatten([for pool, definition in var.node_pools :
    [for _ in range(definition.count) :
      {
        pool_id : pool,
        instance_type : definition.instance_type,
      }
  ]])
}

resource "hcloud_server" "nodes" {
  count = length(local.nodes_servers)

  name        = format("%s.%s", sha1(format("node%02d", count.index + 1)), local.project_name)
  image       = data.hcloud_image.os.name
  server_type = local.nodes_servers[count.index].instance_type

  location  = element(data.hcloud_locations.availability_zones.names, var.control_planes.count + count.index)
  ssh_keys  = local.allowed_ssh_keys
  keep_disk = true

  user_data = <<EOT
#cloud-config
hostname: ${format("%s.%s", sha1(format("node%02d", count.index + 1)), local.project_name)}
  EOT

  labels = {
    "cloud.klst.pw/project"    = local.project_name
    "cloud.klst.pw/type"       = "kubernetes"
    "k3s.klst.pw/cluster-name" = local.project_name
    "k3s.klst.pw/node-type"    = "node"
    "k3s.klst.pw/node-pool"    = local.nodes_servers[count.index].pool_id
  }
}

resource "hcloud_server_network" "nodes" {
  count = length(local.nodes_servers)

  network_id = hcloud_network.main.id
  server_id  = hcloud_server.nodes[count.index].id

  ip = cidrhost(var.network, var.control_planes.count + count.index + 2)
}

resource "hcloud_rdns" "nodes" {
  count = length(local.nodes_servers)

  server_id  = hcloud_server.nodes[count.index].id
  ip_address = hcloud_server.nodes[count.index].ipv4_address
  dns_ptr    = hcloud_server.nodes[count.index].name
}
