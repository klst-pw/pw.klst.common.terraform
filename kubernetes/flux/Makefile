#                                       __
#                                     /\\ \
#                                   /\\ \\ \\
#                                   \// // //
#                                     \//_/
#
#                             K L S T - P r o j e c t
#                                    Makefile
#
# ------------------------------------------------------------------------------

# Install Flux CLI, required to update flux-manifests
install-flux:
	@curl -s https://toolkit.fluxcd.io/install.sh | bash

# Update lastest Flux manifests, based on the instaled CLI
update-flux:
	@flux install --export | yq -s '{"locals":{"flux_manifests": [(.[] | select(. != null))]}}' | sed 's/\$${/$$$${/g'
