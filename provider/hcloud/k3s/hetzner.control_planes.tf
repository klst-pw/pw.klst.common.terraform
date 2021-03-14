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
  control_planes_names = [
    for i in range(var.control_planes.count) : format("%s.%s", substr(sha1(format("cp%02d${local.project_name}", i + 1)), 0, 16), local.project_name)
  ]
}

resource "hcloud_server" "control_planes" {
  count = var.control_planes.count

  name        = local.control_planes_names[count.index]
  image       = data.hcloud_image.os.name
  server_type = var.control_planes.instance_type

  location  = element(data.hcloud_locations.availability_zones.names, count.index)
  ssh_keys  = local.allowed_ssh_keys
  keep_disk = true

  firewall_ids = [hcloud_firewall.control_planes.id]
  user_data    = <<EOT
#cloud-config
hostname: ${local.control_planes_names[count.index]}
  EOT

  labels = {
    "cloud.klst.pw/project"    = local.project_name
    "cloud.klst.pw/type"       = "kubernetes"
    "k3s.klst.pw/cluster-name" = local.project_name
    "k3s.klst.pw/node-type"    = "control-plane"
  }
}

resource "hcloud_server_network" "control_planes" {
  count = length(hcloud_server.control_planes)

  network_id = hcloud_network.main.id
  server_id  = hcloud_server.control_planes[count.index].id

  ip = cidrhost(var.network, count.index + 2)
}

resource "hcloud_rdns" "control_planes" {
  count = length(hcloud_server.control_planes)

  server_id  = hcloud_server.control_planes[count.index].id
  ip_address = hcloud_server.control_planes[count.index].ipv4_address
  dns_ptr    = hcloud_server.control_planes[count.index].name
}

resource "hcloud_firewall" "control_planes" {
  name = "control_planes.fw.${local.project_name}"

  // Apply predefined rules for k3s control planes
  dynamic "rule" {
    for_each = local.k3s_firewall_rules.control_planes
    content {
      direction  = "in"
      protocol   = lower(rule.value.protocol)
      source_ips = rule.value.cidr_blocks
      port       = rule.value.port_range
    }
  }

  // Apply user-defined rules for k3s control planes
  dynamic "rule" {
    for_each = var.control_planes.security_group != null && var.control_planes.security_group.inbound_rules != null ? var.control_planes.security_group.inbound_rules : []
    content {
      direction  = "in"
      protocol   = rule.value.protocol != null ? lower(rule.value.protocol) : "tcp"
      source_ips = rule.value.cidr_blocks
      port       = rule.value.port_range
    }
  }
}
