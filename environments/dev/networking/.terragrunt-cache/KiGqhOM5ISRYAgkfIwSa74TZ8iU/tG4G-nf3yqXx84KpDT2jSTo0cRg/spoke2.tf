locals {
  spoke2_location       = "eastus"
  spoke2_resource_group = "spoke2-vnet-rg"
  prefix_spoke2         = "spoke2"
}

resource "azurerm_resource_group" "spoke2" {
  name     = local.spoke2_resource_group
  location = local.spoke2_location
}

resource "azurerm_virtual_network" "spoke2" {
  name                = "${local.prefix_spoke2}-vnet"
  location            = azurerm_resource_group.spoke2.location
  resource_group_name = azurerm_resource_group.spoke2.name
  address_space       = ["10.2.0.0/16"]

  tags = {
    environment = local.prefix_spoke2
  }
}

resource "azurerm_subnet" "spoke2_mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.spoke2.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefixes     = ["10.2.0.64/27"]
}

resource "azurerm_subnet" "spoke2_workload" {
  name                 = "workload"
  resource_group_name  = azurerm_resource_group.spoke2.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_virtual_network_peering" "spoke2_hub" {
  name                      = "${local.prefix_spoke2}-hub-peer"
  resource_group_name       = azurerm_resource_group.spoke2.name
  virtual_network_name      = azurerm_virtual_network.spoke2.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  # use_remote_gateways     = true
  depends_on = [
    azurerm_virtual_network.spoke2,
    azurerm_virtual_network.hub_vnet,
    # azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}

resource "azurerm_virtual_network_peering" "hub_spoke2" {
  name                         = "hub-spoke2-peer"
  resource_group_name          = azurerm_resource_group.hub_vnet_rg.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  depends_on = [
    azurerm_virtual_network.spoke2,
    azurerm_virtual_network.hub_vnet,
    # azurerm_virtual_network_gateway.hub-vnet-gateway
  ]
}


## Optional (Connectivity testing)
# resource "azurerm_network_interface" "spoke2" {
#     name                 = "${local.prefix_spoke2}-nic"
#     location             = azurerm_resource_group.spoke2.location
#     resource_group_name  = azurerm_resource_group.spoke2.name
#     enable_ip_forwarding = true

#     ip_configuration {
#     name                          = local.prefix_spoke2
#     subnet_id                     = azurerm_subnet.spoke2_mgmt.id
#     private_ip_address_allocation = "Dynamic"
#     }

#     tags = {
#     environment = local.prefix_spoke2
#     }
# }

# resource "azurerm_virtual_machine" "spoke2" {
#     name                  = "${local.prefix_spoke2}-vm"
#     location              = azurerm_resource_group.spoke2.location
#     resource_group_name   = azurerm_resource_group.spoke2.name
#     network_interface_ids = [azurerm_network_interface.spoke2.id]
#     vm_size               = var.vmsize

#     storage_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "16.04-LTS"
#     version   = "latest"
#     }

#     storage_os_disk {
#     name              = "myosdisk1"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#     }

#     os_profile {
#     computer_name  = "${local.prefix_spoke2}-vm"
#     admin_username = var.username
#     admin_password = var.password
#     }

#     os_profile_linux_config {
#     disable_password_authentication = false
#     }

#     tags = {
#     environment = local.prefix_spoke2
#     }
# }