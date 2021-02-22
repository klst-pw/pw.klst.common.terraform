# Terraform Module - Kubernetes apps - Github sync with Flux

![Terraform Version](https://img.shields.io/badge/terraform-≥_0.14-blueviolet)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)


Terraform module which configure `flux` to synchronize apps definitions from a Github repository with the Kubernetes cluster.

> NOTE: using this module, `flux` will only synchronize `*.toolkit.fluxcd.io` resources, reducing mistakes and allowing `applications` management through `git`. **Theses resources must be in the folder `kubernetes/flux-apps`.**

It will create/deploy:
- :key: Deploy key on `github` (`read-write` on the given repository)
- :key: Required RBAC *(all rights for following resources)*
  - `helm.toolkit.fluxcd.io`
  - `kustomize.toolkit.fluxcd.io`
  - `notification.toolkit.fluxcd.io`
  - `source.toolkit.fluxcd.io`
- :octocat: `source.toolkit.fluxcd.io/GitRepository`
  - Synchronize the given repository each minutes
- :rocket: `kustomize.toolkit.fluxcd.io/Kustomization`
  - Deploy `*.toolkit.fluxcd.io` resources with `kustomize` (don’t need the `kustomize.yaml` file)

## Provisionners

- **github:** `integrations/github >= 4.5.0`
- **kubectl:** `gavinbunney/kubectl >= 1.9.1`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
|repository|Gitub repository name (`{org}/{repo}`)|string||yes|
|repository_branch|Gitub repository branch name to be synced|string|`main`|yes|
|no_push|Flux should not push modification on this repo ?|bool|`false`|no|


## Output

### Is_ready

Endpoint used to synchronize other Terraform resources based on this one. Must be used with `depends_on` field.
