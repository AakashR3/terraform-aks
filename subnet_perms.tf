
data "azurerm_subnet" "subnets" {
  for_each = local.subnet_info

  name                 = each.value.name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.rg_name
}

resource "azurerm_role_assignment" "udr_role" {
  for_each = var.network_plugin != "azure" ? data.azurerm_subnet.subnets : {}

  scope                = each.value.route_table_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.user_mi.principal_id
}
