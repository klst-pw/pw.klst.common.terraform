# Terraform Module - Kubernetes apps - Flux

![Terraform Version](https://img.shields.io/badge/terraform-≥_0.14-blueviolet)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)

Terraform module which install `flux` on Kubernetes, using official Helm charts.

## Provisionners

- **kubectl:** `gavinbunney/kubectl >= 1.9.1`
- **kubernetes:** `hashicorp/kubernetes >= 2.0.2`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|

## Output

### Is_ready

Endpoint used to synchronize other Terraform resources based on this one. Must be used with `depends_on` field.

## How to update `flux`

Because `flux` should be installed through the CLI, this module use a `Makefile` to generate Kubernetes manifests from this CLI. To update theses manifests, run `make update-flux > flux-manifests.tf.json` (`flux` must be installed).
