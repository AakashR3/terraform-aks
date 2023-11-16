resource "azurerm_user_assigned_identity" "user_mi" {
  resource_group_name = var.rg_name
  location            = var.location
  tags                = var.tags

  name = "mi-${var.cluster_name}"
}

data "azurerm_resource_group" "example" {
  name     = "Aakash-RG"
}

resource "azurerm_kubernetes_cluster" "cluster" {
  depends_on = [
    azurerm_role_assignment.udr_role
  ]

  name                = "aks-${var.cluster_name}"
  location            = "Central US"
  resource_group_name = "Aakash-RG"

  kubernetes_version = var.kubernetes_version
  # Per design, private_cluster must be enabled
  # private_cluster_enabled             = false
  # private_dns_zone_id                 = "None"
  # private_cluster_public_fqdn_enabled = true
  # Per design, only paid tier is allowed
  sku_tier = "Paid"

  local_account_disabled = var.local_account_disabled

  automatic_channel_upgrade = var.automatic_channel_upgrade
  dns_prefix                = "aks${var.cluster_name}"

  default_node_pool {
    name                  = var.default_node_pool.name
    node_count            = var.default_node_pool.node_count
    vm_size               = var.default_node_pool.vm_size
    type                  = var.default_node_pool.vm_type
    os_disk_size_gb       = var.default_node_pool.os_disk_size_gb
    vnet_subnet_id        = var.default_node_pool.subnet_id
    zones                 = var.enable_availability_zones ? ["3"] : []
    enable_auto_scaling   = var.default_node_pool.enable_autoscaling
    max_count             = var.default_node_pool.enable_autoscaling ? var.default_node_pool.autoscaling_max_nodes : null
    min_count             = var.default_node_pool.enable_autoscaling ? var.default_node_pool.autoscaling_min_nodes : null
    max_pods              = var.default_node_pool.max_pods
    enable_node_public_ip = false

    node_labels = var.default_node_pool.kube_node_labels
  }

  identity {
    type                      = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.user_mi.id]
  }

  # addon_profile {

  #   azure_policy {
  #     enabled = true
  #   }

  #   oms_agent {
  #     enabled                    = var.log_analytics_workspace_id == null ? false : true
  #     log_analytics_workspace_id = var.log_analytics_workspace_id
  #   }

  #   dynamic "ingress_application_gateway" {
  #     for_each = var.appgw_subnet_id != "" ? [0] : []
  #     content {
  #       enabled   = true
  #       subnet_id = var.appgw_subnet_id
  #     }
  #   }
  # }

  network_profile {
    network_plugin     = lower(var.network_plugin)
    network_policy     = lower(var.network_plugin) == "azure" ? "azure" : "calico"
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
    pod_cidr           = lower(var.network_plugin) == "kubenet" ? var.pod_cidr : null
    service_cidr       = var.service_cidr
  }
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.enable_role_based_access_control && var.rbac_aad_managed ? ["rbac"] : []

    content {
      # enabled = true
      # azure_active_directory {
        managed                = true
        azure_rbac_enabled     = true
        admin_group_object_ids = concat(var.rbac_aad_admin_group_object_ids)
      # }
    }
  }
  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "node_pools" {
  for_each = var.node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.cluster.id

  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  vnet_subnet_id        = each.value.subnet_id
  os_disk_size_gb       = each.value.os_disk_size_gb
  zones                 = var.enable_availability_zones ? ["1", "2", "3"] : null
  os_type               = "Linux"
  enable_node_public_ip = false

  node_labels = each.value.kube_node_labels

  enable_auto_scaling = each.value.enable_autoscaling
  max_count           = each.value.enable_autoscaling ? each.value.autoscaling_max_nodes : null
  min_count           = each.value.enable_autoscaling ? each.value.autoscaling_min_nodes : null
  max_pods            = each.value.max_pods

  tags = var.tags
}

# # Enable Azure Defender for Cloud for cluster
# resource "azurerm_advanced_threat_protection" "defender" {
#   target_resource_id = azurerm_kubernetes_cluster.cluster.id
#   enabled            = true
# }


# Add the managed identity
# Set the permissions RBAC for the routing table
