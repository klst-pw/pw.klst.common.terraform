# Terraform Module - Kubernetes apps - HetznerCloud controllers

![Terraform Version](https://img.shields.io/badge/terraform-≥_0.14-blueviolet)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)

Terraform module which provision a Kubernetes cluster with HetznerCloud controllers (CCM & CSI).

It will deploy:
- :key: HetznerCloud secret token
- :satellite: HetznerCloud cloud controller manager
  - RBAC (ServiceAccount + Roles)
  - Deployment
- :floppy_disk: HetznerCloud CSI controller
  - CSI Driver `csi.hetzner.cloud`
  - StorageClass `hetzner.cloud`
  - RBAC
  - Deployment (controller)
  - Daemonset (node provisioner)

## Provisionners

- **kubernetes:** `hashicorp/kubernetes >= 2.0.2`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|hcloud_token|HetznerCloud API token (RW).|string||yes|
|namespace|Namespace where all hetzner component will de deployed.|string|kube-system|no|
|hcloud_network|HetznerCloud network information.|object({name = string, cidr = string})||yes|
|is_default_class|Is HetznerCloud storage class default storage class ?|bool|true|no|

## Output

### is_ready

Endpoint used to synchronize other Terraform resources based on this one. Must be used with `depends_on` field.

> NOTE: unlike others `Kubernetes apps`, this endpoint is "unlocked" when resources are deployed and not when the Operator is ready (allowing us to used it before `CNI`).
