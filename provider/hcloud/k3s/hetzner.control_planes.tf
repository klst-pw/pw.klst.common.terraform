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

resource "hcloud_server" "control_planes" {
  count = var.control_planes.count

  name        = format("%s.%s", sha1(format("cp%02d", count.index + 1)), local.project_name)
  image       = data.hcloud_image.os.name
  server_type = var.control_planes.instance_type

  location  = element(data.hcloud_locations.availability_zones.names, count.index)
  ssh_keys  = local.allowed_ssh_keys
  keep_disk = true

  user_data = <<EOT
#cloud-config
hostname: ${format("%s.%s", sha1(format("cp%02d", count.index + 1)), local.project_name)}
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
