# Terraform Module - Kubernetes apps - `prometheus-operator-standalone`

![Terraform Version](https://img.shields.io/badge/terraform-≥_0.14-blueviolet)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)


Terraform module which install `prometheus-operator-standalone` on Kubernetes, using BanzaiCloud Helm charts. 

> NOTE: It is recommended to use this chart before other `Kubernetes apps` modules as it installs Prometheus CRDs (like` ServiceMonitor`), required by many others.

## Provisionners

- **helm:** `hashicorp/helm >= 2.0.0`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|chart_version|Prometheus operator chart version|string||yes|
|operator_version|Prometheus operator version|string||yes|

## Output

### is_ready

Endpoint used to synchronize other Terraform resources based on this one. Must be used with `depends_on` field.

> NOTE: unlike others `Kubernetes apps`, this endpoint is "unlocked" when resources are deployed and not when the Operator is ready (allowing us to used it before `CNI`).
