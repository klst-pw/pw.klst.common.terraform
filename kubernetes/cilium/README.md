# Terraform Module - Kubernetes apps - `cilium`

![Terraform Version](https://img.shields.io/badge/terraform-≥_0.14-blueviolet)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)


Terraform module which install `cilium` on Kubernetes, using official Helm charts. 

> NOTE: `hubble` is installed next Cilium with metrics endpoint enabled, but `hubble-ui` is disabled by default.

## Provisionners

- **helm:** `hashicorp/helm >= 2.0.0`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|cilium_version|Cilium chart version|string||yes|
|enable_hubble|Enable Hubble UI|bool|`false`|no|

## Output

### Is_ready

Endpoint used to synchronize other Terraform resources based on this one. Must be used with `depends_on` field.
