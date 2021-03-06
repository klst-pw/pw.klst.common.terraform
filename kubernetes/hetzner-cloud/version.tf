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
  required_version = "~> 0.14.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
  }
}
