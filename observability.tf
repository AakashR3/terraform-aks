resource "azurerm_monitor_diagnostic_setting" "sentinel_diag" {
  name                       = "sentinel-m"
  target_resource_id         = azurerm_kubernetes_cluster.cluster.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "log" {
    for_each = var.diagnostic_logs_categories
    content {
      category = log.value
      enabled  = true
      retention_policy {
        enabled = false
      }
    }
  }
}