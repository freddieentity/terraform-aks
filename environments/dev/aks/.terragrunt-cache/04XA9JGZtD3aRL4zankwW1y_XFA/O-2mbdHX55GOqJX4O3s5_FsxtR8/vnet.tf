resource "azurerm_resource_group" "main" {
  name     = var.resource_group
  location = var.azure_location
}

resource "azurerm_virtual_network" "main" {
  name                = "mainvnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.1.0.0/16"]

}

resource "azurerm_subnet" "mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.1.0.64/27"]
}