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
  nodes_names = [
    for i in range(length(local.nodes_servers)) : format("%s.%s", substr(sha1(format("node%02d${local.project_name}", i + 1)), 0, 16), local.project_name)
  ]

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

  name        = local.nodes_names[count.index]
  image       = data.hcloud_image.os.name
  server_type = local.nodes_servers[count.index].instance_type

  location  = element(data.hcloud_locations.availability_zones.names, var.control_planes.count + count.index)
  ssh_keys  = local.allowed_ssh_keys
  keep_disk = true

  firewall_ids = [hcloud_firewall.nodes[local.nodes_servers[count.index].pool_id].id]
  user_data    = <<EOT
#cloud-config
hostname: ${local.nodes_names[count.index]}
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

resource "hcloud_firewall" "nodes" {
  for_each = var.node_pools
  name     = "${each.key}.node_pools.fw.${local.project_name}"

  // Apply predefined rules for k3s nodes
  dynamic "rule" {
    for_each = local.k3s_firewall_rules.nodes
    content {
      direction  = "in"
      protocol   = lower(rule.value.protocol)
      source_ips = rule.value.cidr_blocks
      port       = rule.value.port_range
    }
  }

  // Apply user-defined rules for k3s node pool
  dynamic "rule" {
    for_each = each.value.security_group != null && each.value.security_group.inbound_rules != null ? each.value.security_group.inbound_rules : []
    content {
      direction  = "in"
      protocol   = rule.value.protocol != null ? lower(rule.value.protocol) : "tcp"
      source_ips = rule.value.cidr_blocks
      port       = rule.value.port_range
    }
  }
}
