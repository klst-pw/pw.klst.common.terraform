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

output "service_account_token" {
  description = "Generated ServiceAccount token for cluster bootstrap."
  sensitive   = true
  value       = data.kubernetes_secret.kube_bootstrap_token.data.token
}
