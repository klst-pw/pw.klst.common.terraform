# Terraform - Hetzner Cloud

This library contains modules to easily deploy infrastructure on hetzner-cloud.

## Kubernetes clusters
- [k3s](k3s): creates a kubernetes-light cluster ([k3s](https://k3s.io/)) on Hetzner Cloud
  - **manage** multi control-planes *(don't use machine lower than `CX21`)*
  - **manage** node pools
  - **generate** `kubeconfig` with *cluster-admin* rights *(not recommended for production)*
  - **generate** Kubernetes service-account with *cluster-admin* rights, which can be used by Terraform to provision Kubernetes resources
