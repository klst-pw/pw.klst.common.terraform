# Terraform - Kubernetes Apps

This library contains Kubernetes "apps" used to provision our Kubernetes clusters directly through Terraform.

## Available applications
### Cloud providers
- [Hetzner-Cloud controllers (CCM & CSI)](hetzner-cloud)

### Network
- [Cert-Manager](cert-manager)
- [Cilium](cilium)
  - Cilium & Hubble install (Hubble UI optional)
- [External DNS](external-dns)
- [Ingress NGINX](ingress-nginx)

### Observability
- [Prometheus operator standalone](prometheus-operator-standalone)

### CI/CD
- [Flux](flux)
  - Only flux system
- [Flux github sync](flux-github-sync)
  - Configure Github repository & flux to synchronize them together
  - :warning: **Flux will only synchronize the directory `kubernetes/flux-apps` and only `*.toolkit.fluxcd.io` resources**
