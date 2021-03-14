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

variable "image" {
  description = "Specify the image to be used."
  type        = string
  default     = "ubuntu-20.04"
}

variable "user" {
  description = "Specify the user to be used."
  type        = string
  default     = "root"
}

variable "network" {
  description = "Hetzner network CIDR."
  type        = string
  default     = "172.16.1.0/24"

  validation {
    condition     = can(cidrsubnets(var.network, 8))
    error_message = "Field network must be a valid IPv4 and must be a /24 network."
  }
  validation {
    condition     = !can(cidrsubnets(var.network, 9))
    error_message = "Field network must be a valid IPv4 and must be a /24 network."
  }
}
