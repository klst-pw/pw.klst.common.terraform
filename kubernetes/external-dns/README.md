# Terraform Module - Kubernetes apps - `external-dns`

![Terraform Version](https://img.shields.io/badge/terraform-≥_0.14-blueviolet)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)


Terraform module which install `external-dns` on Kubernetes, using official Helm charts. 

> **NOTE: this module is not tested and should not works**
> **NOTE: this module IS CURRENTLY NOT SECURE**

## Provisionners

- **helm:** `hashicorp/helm >= 2.0.0`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|external_dns_version|External DNS chart version|string||yes|
|dns_provider|External DNS provider|string||yes|
|configuration|External DNS settings|object||yes|

> **NOTE: `configuration` IS CURRENTLY NOT SECURE**

## Output

### Is_ready

Endpoint used to synchronize other Terraform resources based on this one. Must be used with `depends_on` field.
