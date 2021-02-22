#                                       __
#                                     /\\ \
#                                   /\\ \\ \\
#                                   \// // //
#                                     \//_/
#
#                             K L S T - P r o j e c t
#                                Terraform  Module
#
# ------------------------------------------------------------------------------

# NOTE: currently, RBAC are only additive; no "deny" rules allowed.
#
# locals {
#   blacklisted_clustered_resources = [
#     {
#       "api_groups" : [""],
#       "resources" : ["componentstatuses"],
#       "verbs" : [""],
#       "resource_names" : [
#         "controller-manager",
#         "scheduler"
#       ]
#     },
#     {
#       "api_groups" : [""],
#       "resources" : ["namespaces"],
#       "verbs" : [""],
#       "resource_names" : [
#         "kube-system"
#       ]
#     },
#     {
#       "api_groups" : ["apiextensions.k8s.io"],
#       "resources" : ["customresourcesdefinitions"]
#       "verbs" : [""],
#       "resource_names" : [
#         "addons.k3s.cattle.io"
#       ]
#     },
#     {
#       "api_groups" : ["flowcontrol.apiserver.k8s.io"],
#       "resources" : ["flowschemas"],
#       "verbs" : [""],
#       "resource_names" : [
#         "catch-all",
#         "exempt",
#         "global-default",
#         "kube-controller-manager",
#         "kube-scheduler",
#         "kube-system-service-accounts",
#         "service-accounts",
#         "system-leader-election",
#         "system-nodes",
#         "workload-leader-election"
#       ]
#     },
#     {
#       "api_groups" : ["flowcontrol.apiserver.k8s.io"],
#       "resources" : ["prioritylevelconfigurations"],
#       "verbs" : [""],
#       "resource_names" : [
#         "catch-all",
#         "exempt",
#         "global-default",
#         "leader-election",
#         "system",
#         "workload-high",
#         "workload-low"
#       ]
#     },
#     {
#       "api_groups" : ["rbac.authorization.k8s.io"],
#       "resources" : ["clusterrolebindings"],
#       "verbs" : [""],
#       "resource_names" : [
#         "cluster-admin",
#         "kube-apiserver-kubelet-admin",
#         "local-path-provisioner-bind",
#         "metrics-server:system:auth-delegator",
#         "system:basic-user",
#         "system:controller:attachdetach-controller",
#         "system:controller:certificate-controller",
#         "system:controller:clusterrole-aggregation-controller",
#         "system:controller:cronjob-controller",
#         "system:controller:daemon-set-controller",
#         "system:controller:deployment-controller",
#         "system:controller:disruption-controller",
#         "system:controller:endpoint-controller",
#         "system:controller:endpointslice-controller",
#         "system:controller:endpointslicemirroring-controller",
#         "system:controller:expand-controller",
#         "system:controller:generic-garbage-collector",
#         "system:controller:horizontal-pod-autoscaler",
#         "system:controller:job-controller",
#         "system:controller:namespace-controller",
#         "system:controller:node-controller",
#         "system:controller:persistent-volume-binder",
#         "system:controller:pod-garbage-collector",
#         "system:controller:pv-protection-controller",
#         "system:controller:pvc-protection-controller",
#         "system:controller:replicaset-controller",
#         "system:controller:replication-controller",
#         "system:controller:resourcequota-controller",
#         "system:controller:root-ca-cert-publisher",
#         "system:controller:route-controller",
#         "system:controller:service-account-controller",
#         "system:controller:service-controller",
#         "system:controller:statefulset-controller",
#         "system:controller:ttl-controller",
#         "system:coredns",
#         "system:discovery",
#         "system:k3s-controller",
#         "system:kube-controller-manager",
#         "system:kube-dns",
#         "system:kube-scheduler",
#         "system:metrics-server",
#         "system:monitoring",
#         "system:node",
#         "system:node-proxier",
#         "system:public-info-viewer",
#         "system:volume-scheduler"
#       ]
#     },
#     {
#       "api_groups" : ["rbac.authorization.k8s.io"],
#       "resources" : ["clusterroles"],
#       "verbs" : [""],
#       "resource_names" : [
#         "admin",
#         "cluster-admin",
#         "edit",
#         "local-path-provisioner-role",
#         "system:aggregate-to-admin",
#         "system:aggregate-to-edit",
#         "system:aggregate-to-view",
#         "system:aggregated-metrics-reader",
#         "system:auth-delegator",
#         "system:basic-user",
#         "system:certificates.k8s.io:certificatesigningrequests:nodeclient",
#         "system:certificates.k8s.io:certificatesigningrequests:selfnodeclient",
#         "system:certificates.k8s.io:kube-apiserver-client-approver",
#         "system:certificates.k8s.io:kube-apiserver-client-kubelet-approver",
#         "system:certificates.k8s.io:kubelet-serving-approver",
#         "system:certificates.k8s.io:legacy-unknown-approver",
#         "system:controller:attachdetach-controller",
#         "system:controller:certificate-controller",
#         "system:controller:clusterrole-aggregation-controller",
#         "system:controller:cronjob-controller",
#         "system:controller:daemon-set-controller",
#         "system:controller:deployment-controller",
#         "system:controller:disruption-controller",
#         "system:controller:endpoint-controller",
#         "system:controller:endpointslice-controller",
#         "system:controller:endpointslicemirroring-controller",
#         "system:controller:expand-controller",
#         "system:controller:generic-garbage-collector",
#         "system:controller:horizontal-pod-autoscaler",
#         "system:controller:job-controller",
#         "system:controller:namespace-controller",
#         "system:controller:node-controller",
#         "system:controller:persistent-volume-binder",
#         "system:controller:pod-garbage-collector",
#         "system:controller:pv-protection-controller",
#         "system:controller:pvc-protection-controller",
#         "system:controller:replicaset-controller",
#         "system:controller:replication-controller",
#         "system:controller:resourcequota-controller",
#         "system:controller:root-ca-cert-publisher",
#         "system:controller:route-controller",
#         "system:controller:service-account-controller",
#         "system:controller:service-controller",
#         "system:controller:statefulset-controller",
#         "system:controller:ttl-controller",
#         "system:coredns",
#         "system:discovery",
#         "system:heapster",
#         "system:k3s-controller",
#         "system:kube-aggregator",
#         "system:kube-controller-manager",
#         "system:kube-dns",
#         "system:kube-scheduler",
#         "system:kubelet-api-admin",
#         "system:metrics-server",
#         "system:monitoring",
#         "system:node",
#         "system:node-bootstrapper",
#         "system:node-problem-detector",
#         "system:node-proxier",
#         "system:persistent-volume-provisioner",
#         "system:public-info-viewer",
#         "system:volume-scheduler",
#         "view"
#       ]
#     },
#     {
#       "api_groups" : ["scheduling.k8s.io"],
#       "resources" : ["priorityclasses"],
#       "verbs" : [""],
#       "resource_names" : [
#         "system-cluster-critical",
#         "system-node-critical"
#       ]
#     },
#     {
#       "api_groups" : ["storage.k8s.io"],
#       "resources" : ["storageclasses"],
#       "verbs" : [""],
#       "resource_names" : [
#         "local-path"
#       ]
#     }
#   ]

#   blacklisted_namespaced_resources = {
#     "kube-system" : [
#       {
#         "api_groups" : [""],
#         "resources" : ["configmaps"],
#         "verbs" : [""],
#         "resource_names" : [
#           "cluster-dns",
#           "coredns",
#           "extension-apiserver-authentication",
#           "kube-root-ca.crt",
#           "local-path-config"
#         ]
#       },
#       {
#         "api_groups" : [""],
#         "resources" : ["endpoints"],
#         "verbs" : [""],
#         "resource_names" : [
#           "kube-dns",
#           "metrics-server"
#         ]
#       },
#       {
#         "api_groups" : [""],
#         "resources" : ["secrets"],
#         "verbs" : [""],
#         "resource_names" : [
#           "k3s-serving"
#         ]
#       },
#       {
#         "api_groups" : [""],
#         "resources" : ["serviceaccounts"],
#         "verbs" : [""],
#         "resource_names" : [
#           "attachdetach-controller",
#           "certificate-controller",
#           "clusterrole-aggregation-controller",
#           "coredns",
#           "cronjob-controller",
#           "daemon-set-controller",
#           "default",
#           "deployment-controller",
#           "disruption-controller",
#           "endpoint-controller",
#           "endpointslice-controller",
#           "endpointslicemirroring-controller",
#           "expand-controller",
#           "generic-garbage-collector",
#           "horizontal-pod-autoscaler",
#           "job-controller",
#           "local-path-provisioner-service-account",
#           "metrics-server",
#           "namespace-controller",
#           "node-controller",
#           "persistent-volume-binder",
#           "pod-garbage-collector",
#           "pv-protection-controller",
#           "pvc-protection-controller",
#           "replicaset-controller",
#           "replication-controller",
#           "resourcequota-controller",
#           "root-ca-cert-publisher",
#           "service-account-controller",
#           "service-controller",
#           "statefulset-controller",
#           "ttl-controller"
#         ]
#       },
#       {
#         "api_groups" : [""],
#         "resources" : ["services"],
#         "verbs" : [""],
#         "resource_names" : [
#           "kube-dns",
#           "metrics-server"
#         ]
#       },
#       {
#         "api_groups" : ["apps"],
#         "resources" : ["deployments"],
#         "verbs" : [""],
#         "resource_names" : [
#           "coredns",
#           "local-path-provisioner",
#           "metrics-server"
#         ]
#       },
#       {
#         "api_groups" : ["apps"],
#         "resources" : ["statefulsets"],
#         "verbs" : [""],
#         "resource_names" : [
#           "hcloud-csi-controller"
#         ]
#       },
#       {
#         "api_groups" : ["k3s.cattle.io"],
#         "resources" : ["addons"],
#         "verbs" : [""],
#         "resource_names" : [
#           "aggregated-metrics-reader",
#           "auth-delegator",
#           "auth-reader",
#           "coredns",
#           "local-storage",
#           "metrics-apiservice",
#           "metrics-server-deployment",
#           "metrics-server-service",
#           "resource-reader",
#           "rolebindings"
#         ]
#       },
#       {
#         "api_groups" : ["rbac.authorization.k8s.io"],
#         "resources" : ["rolebindings"],
#         "verbs" : [""],
#         "resource_names" : [
#           "metrics-server-auth-reader",
#           "system::extension-apiserver-authentication-reader",
#           "system::leader-locking-kube-controller-manager",
#           "system::leader-locking-kube-scheduler",
#           "system:controller:bootstrap-signer",
#           "system:controller:cloud-provider",
#           "system:controller:token-cleaner"
#         ]
#       },
#       {
#         "api_groups" : ["rbac.authorization.k8s.io"],
#         "resources" : ["roles"],
#         "verbs" : [""],
#         "resource_names" : [
#           "extension-apiserver-authentication-reader",
#           "system::leader-locking-kube-controller-manager",
#           "system::leader-locking-kube-scheduler",
#           "system:controller:bootstrap-signer",
#           "system:controller:cloud-provider",
#           "system:controller:token-cleaner"
#         ]
#       }
#     ]
#   }
# }
