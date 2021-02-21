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

terraform {
  experiments      = [module_variable_optional_attrs]
  required_version = "~> 0.14.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.23.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
  }
}
