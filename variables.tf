
variable "appgw_subnet_id" {
  type        = string
  description = "Application Gateway Subnet ID. Specifying this creates an application gateway"
  default     = ""
}

variable "automatic_channel_upgrade" {
  type        = string
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable. Defaults to none."
  default     = "none"

  validation {
    condition     = contains(["patch", "rapid", "node-image", "stable", "none"], lower(var.automatic_channel_upgrade))
    error_message = "The value must be a valid string. patch, rapid, node-image or stable. Defaults to none."
  }
}

variable "cluster_name" {
  type        = string
  description = "Cluster Name"
  default = "testing"
}

variable "create_groups" {
  type        = bool
  description = "Create RBAC Groups"
  default     = true
}

variable "default_node_pool" {
  type = object({
    name                  = string
    node_count            = number
    vm_size               = string
    vm_type               = string
    os_disk_size_gb       = number
    subnet_id             = string
    enable_autoscaling    = bool
    max_pods              = number
    autoscaling_min_nodes = number
    autoscaling_max_nodes = number
    kube_node_labels      = map(string)
  })
  description = "Default Node Pool Definition. Must be defined"
}

variable "node_pools" {
  type = map(object({
    node_count            = number
    vm_size               = string
    os_disk_size_gb       = number
    subnet_id             = string
    enable_autoscaling    = bool
    max_pods              = number
    autoscaling_min_nodes = number
    autoscaling_max_nodes = number
    kube_node_labels      = map(string)
  }))
  description = "Node Pool Definitions. Default Node Pool must be defined"
}


variable "dns_service_ip" {
  type        = string
  description = "DNS Service IP (typically in var.service_cidr ending in .10)"
  default     = "192.168.0.10"
}


variable "docker_bridge_cidr" {
  type        = string
  description = "Docker Bridge CIDR range"
  default     = "172.17.0.1/16"
}


variable "enable_availability_zones" {
  type        = bool
  description = "Enable Availability Zones"
  default     = true
}

variable "enable_role_based_access_control" {
  description = "Is Role Based Access Control Enabled?"
  type        = bool
  default     = true
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version to deploy"
  default     = "1.24.3"
}

variable "local_account_disabled" {
  type        = bool
  description = "Disable local account for node authentication"
  default     = true
}
variable "location" {
  type        = string
  description = "Cluster Location"
  default = "Central US"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace resource id"
}

variable "network_plugin" {
  type        = string
  description = "Network plugin to use. Options: kubenet or azure (default)"
  default     = "azure"
  validation {
    condition     = contains(["azure", "kubenet"], lower(var.network_plugin))
    error_message = "Currently supported values are azure and kubenet. Defaults to azure."
  }
}

variable "pod_cidr" {
  type        = string
  description = "Pod  CIDR range"
  default     = "192.169.0.0/16"
}

variable "rg_name" {
  type        = string
  description = "Resource Group Name"
  default = "Aakash-RG"
}

variable "rbac_aad_managed" {
  description = "Is Role Based Access Control based on Azure AD enabled?"
  type        = bool
  default     = true
}

variable "rbac_aad_admin_group_object_ids" {
  description = "Object ID of groups with admin access."
  type        = list(string)
  default     = []
}

variable "service_cidr" {
  type        = string
  description = "Service  CIDR range"
  default     = "192.168.0.0/16"
}

variable "tags" {
  type        = map(any)
  description = "Azure Tags"
  default     = {}
}

variable "diagnostic_logs_categories" {
  description = "Diagnostic logs categories"
  type        = list(string)
  default     = ["guard", "kube-audit", "kube-audit-admin"]
}
