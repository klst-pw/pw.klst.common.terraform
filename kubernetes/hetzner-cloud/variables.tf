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

variable "hcloud_token" {
  description = "HetznerCloud API token."
  sensitive   = true
  type        = string
}

variable "hcloud_network" {
  description = "HetznerCloud network information."
  type = object({
    name = string
    cidr = string
  })

  validation {
    condition     = length(var.hcloud_network.name) > 0
    error_message = "Network name is required for the cloud controller manager of HetznerCloud."
  }

  validation {
    condition     = length(var.hcloud_network.cidr) > 0
    error_message = "Network CIDR is required for the cloud controller manager of HetznerCloud."
  }

  validation {
    condition     = can(cidrhost(var.hcloud_network.cidr, 0))
    error_message = "Network CIDR must be a valid IP address."
  }
}

variable "is_default_class" {
  description = "Is HetznerCloud storage class default storage class ?"
  type        = bool
  default     = false
}