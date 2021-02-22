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

variable "external_dns_version" {
  description = "External DNS release version."
  type        = string
}

variable "dns_provider" {
  description = "External DNS provider."
  type        = string
}

variable "configuration" {
  description = "External DNS configuration (see https://artifacthub.io/packages/helm/bitnami/external-dns)."
  type        = map(any)
  sensitive   = true
}
