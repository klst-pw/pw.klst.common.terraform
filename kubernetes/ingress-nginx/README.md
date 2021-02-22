# Terraform Module - Kubernetes apps - `ingress-nginx`

![Terraform Version](https://img.shields.io/badge/terraform-≥_0.14-blueviolet)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)


Terraform module which install `ingress-nginx` on Kubernetes, using Bitnami Helm charts. 

## Provisionners

- **helm:** `hashicorp/helm >= 2.0.0`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|ingress_version|NGINX ingress controller chart version|string||yes|

## Output

### Is_ready

Endpoint used to synchronize other Terraform resources based on this one. Must be used with `depends_on` field.
