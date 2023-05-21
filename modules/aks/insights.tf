# resource "azurerm_log_analytics_workspace" "main" {
#   name                = "${local.name}-insights"
#   location            = azurerm_resource_group.spoke.location
#   resource_group_name = azurerm_resource_group.spoke.name
#   retention_in_days   = 30
# }
