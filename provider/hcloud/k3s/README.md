# Terraform Module - k3s on Hetzner Cloud

![Terraform Version](https://img.shields.io/badge/terraform-≥_0.14-blueviolet)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)


Terraform module which creates a kubernetes-light cluster ([k3s](https://k3s.io/)) on Hetzner Cloud.

## Provisionners

- **hcloud:** `hetznercloud/hcloud >= 1.23.0`
- **kubernetes:** `hashicorp/kubernetes >= 2.0.2`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|name|Klst project name (shoud be related to the Hetzner project)|string||yes|
|sub_name|Klst sub project name.|string||no|
|teams|List of teams allowed to manage/access to this project.|list(string)||yes|
|image|Specify the image to be used.|string|`ubuntu-20.04`|no|
|user|Specify the user to be used.|string|`root`|no|
|network|Hetzner network CIDR.|string||yes|
|k3s_version|Specify the k3s version. You can choose from the following release channels or pin the version directly.|string|`latest`|no|
|drain_timeout|The length of time to wait before giving up the node draining. 30s by default.|string|30s|no|
|k3s_args|Add additional installation flags, used by all nodes (see https://rancher.com/docs/k3s/latest/en/installation/install-options/).|list(string)|`[]`|no|
|control_planes|Control-plane nodes definitions.|[NodePoolDefinition](#NodePoolDefinition)||yes|
|node_pools|Nodes pools definitions.|map([NodePoolDefinition](#NodePoolDefinition))<sup>[[1]](#node-pool-key)</sup>|{}|no|

> <a name="node-pool-key">[1]</a>: **key** is node-pool name.

### NodePoolDefinition

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|count|Number of control-plane (**NOTE**: must be an odd number for control-planes).|number||yes|
|instance_type|[Type](https://www.hetzner.com/cloud#pricing) of the Hetzner machine.|string||yes|
|k3s_args|Additional installation flags used by all control planes (see https://rancher.|list(string)|[]|no|
|annotations|Additional node annotations used by all control planes.|map(string)||no|
|taints|Additional node taints used by all control planes|map(string)||no|
|labels|Additional node labels used by all control planes.|map(string)||no|

## Output

### Kubeconfig (`sensitive`)

> **NOTE: do not output this value on production environment**

A kubeconfig for the cluster-root user is generated during the cluster generation and can be accessed through the `kubeconfig` output, formatted in YAML.

### Service Account (`sensitive`)

A ServiceAccount is generated, binded with the given RBAC rules. It can be used by Terraform to provision a fresh new Kubernetes.

### Summary

A brief summary is available through the `summary` output. It contains:
- Information about the `VPC`; its *own CIDR* and the addresses of the *nodes*, *pods* and *services* subnets
- A KLST inventory about theses machines *(an Ansible-like inventory to be used in other modules)*
- The kubernetes metadata; `annotations`, `labels` and `taints` of each nodes, and the k3s version used to bootstrap this cluster. ***(Be carefull on auto-managed clusters)***
