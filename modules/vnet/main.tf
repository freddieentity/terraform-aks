resource "azurerm_resource_group" "main" {
  name     = var.application
  location = var.azure_location
}

resource "azurerm_virtual_network" "hub" {
  name                = "${var.application}-hub-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = var.hub_address_space
}

resource "azurerm_subnet" "hub" {
  for_each             = var.hub_subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.application}-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = var.spoke_address_space
}

resource "azurerm_subnet" "main" {
  for_each             = var.spoke_subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = each.value.address_prefixes
}