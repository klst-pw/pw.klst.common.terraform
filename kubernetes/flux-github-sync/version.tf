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
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 4.5.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.9.1"
    }
  }
}
