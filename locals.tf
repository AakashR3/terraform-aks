locals {
  # Groups that will receive Azure RBAC Roles
  groups = var.create_groups ? {
    #List cluster admin credential action
    "ClusterAdmin" = "Azure Kubernetes Service Cluster Admin Role"
    #List cluster user credential action
    "ClusterUser" = "Azure Kubernetes Service Cluster User Role"
    #Grants access to read and write Azure Kubernetes Service clusters
    "ClusterContributor" = "Azure Kubernetes Service Contributor Role"
    #Lets you manage all resources under cluster/namespace, except update or delete resource quotas and namespaces.
    "RBACAdmin" = "Azure Kubernetes Service RBAC Admin"
    #Lets you manage all resources in the cluster.
    "RBACClusterAdmin" = "Azure Kubernetes Service RBAC Cluster Admin"
    #Allows read-only access to see most objects in a namespace
    "RBACClusterReader" = "Azure Kubernetes Service RBAC Reader"
    #Allows read/write access to most objects in a namespace.This role does not allow viewing or modifying roles or role bindings. However, this role allows accessing Secrets and running Pods as any ServiceAccount in the namespace, so it can be used to gain the API access levels of any ServiceAccount in the namespace.
    "RBACClusterWriter" = "Azure Kubernetes Service RBAC Writer"
  } : {}

  np_subnet_ids = flatten([
    for np in var.node_pools : [
      np.subnet_id
    ]
  ])
  node_subnet_ids = distinct(concat([var.default_node_pool.subnet_id], local.np_subnet_ids))

  subnet_info = { for sn in local.node_subnet_ids : sn => {
    name      = split("/", sn)[10]
    rg_name   = split("/", sn)[4]
    vnet_name = split("/", sn)[8]
    }
  }
}
