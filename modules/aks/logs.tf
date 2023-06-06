resource "azurerm_log_analytics_workspace" "main" {
  name                = "my-own-insights"
  resource_group_name = var.resource_group
  location            = var.azure_location
  retention_in_days   = 30
}
