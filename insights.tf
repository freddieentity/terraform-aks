resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.name}-insights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  retention_in_days   = 30
}