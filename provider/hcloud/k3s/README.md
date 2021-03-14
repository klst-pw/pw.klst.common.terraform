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
|teams|List of teams allowed to manage/access to this project.|list(string)|[]|no|
|image|Specify the image to be used.|string|`ubuntu-20.04`|no|
|user|Specify the user to be used.|string|`root`|no|
|network|Hetzner network CIDR.|string||yes|
|k3s_version|Specify the k3s version. You can choose from the following release channels or pin the version directly.|string|`latest`|no|
|drain_timeout|The length of time to wait before giving up the node draining. 30s by default.|string|30s|no|
|k3s_args|Add additional installation flags, used by all nodes (see https://rancher.com/docs/k3s/latest/en/installation/install-options/).|list(string)|`[]`|no|
|control_planes_as_bastion|Use control-plane nodes as bastion.|boolean|false|no|
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
|security_group|Additional security groups applied on nodes.|[SecurityGroupDefinition](#SecurityGroupDefinition)<sup>[[2]](#default-security-group)</sup>||no|

> <a name="default-security-group">[2]</a>: *by default*, only **SSH** port is allowed for control-planes.

### SecurityGroupDefinition

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|inbound_rules|List of inbound rules.|list([SecurityRuleDefinition](#SecurityRuleDefinition))||no|
|outbound_rules|List of outbound rules.|list([SecurityRuleDefinition](#SecurityRuleDefinition))<sup>[[3]](#ignored-outbound)</sup>||no|

> <a name="ignored-outbound">[3]</a>: outbound rules are currently ignored on Hetzner FW.

### SecurityRuleDefinition

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|protocol|Protocol of the Firewall Rule (`ICMP`,`TCP` or `UDP`).|string|`TCP`|no|
|cidr_blocks|List of CIDRs that are allowed within this Firewall Rule.|list(string)||yes|
|port_range|Port of the Firewall Rule.|string||yes|

> <a name="fw-port-range">[4]</a>:  A port range can be specified by separating two ports with a dash, e.g `1024-5000`.

## Output

### *Kubeconfig (`kubeconfig`)

> **NOTE: do not output this value on production environment**

A kubeconfig for the cluster-root user is generated during the cluster generation and can be accessed through the `kubeconfig` output, formatted in YAML.

### *Service Account (`service_account`)

A ServiceAccount is generated, binded with the given RBAC rules. It can be used by Terraform to provision a fresh new Kubernetes.

### Summary (`summary`)

A brief summary is available through the `summary` output. It contains:
- Information about the `VPC`; its *own CIDR* and the addresses of the *nodes*, *pods* and *services* subnets
- A KLST inventory about theses machines *(an Ansible-like inventory to be used in other modules)*
- The kubernetes metadata; `annotations`, `labels` and `taints` of each nodes, and the k3s version used to bootstrap this cluster. ***(Be careful on auto-managed clusters)***
