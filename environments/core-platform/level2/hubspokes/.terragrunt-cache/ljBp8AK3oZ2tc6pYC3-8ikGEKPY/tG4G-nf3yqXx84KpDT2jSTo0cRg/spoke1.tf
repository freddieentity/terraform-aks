locals {
  spoke1_location       = "eastus"
  spoke1_resource_group = "spoke1-vnet-rg"
  prefix_spoke1         = "spoke1"
}

resource "azurerm_resource_group" "spoke1" {
  name     = local.spoke1_resource_group
  location = local.spoke1_location
}

resource "azurerm_virtual_network" "spoke1" {
  name                = "spoke1"
  location            = azurerm_resource_group.spoke1.location
  resource_group_name = azurerm_resource_group.spoke1.name
  address_space       = ["10.1.0.0/16"]

  tags = {
    environment = local.prefix_spoke1
  }
}

resource "azurerm_subnet" "spoke1_mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.spoke1.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefixes     = ["10.1.0.64/27"]
}

resource "azurerm_subnet" "spoke1_workload" {
  name                 = "workload"
  resource_group_name  = azurerm_resource_group.spoke1.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_virtual_network_peering" "hub_spoke1" {
  name                         = "hub-spoke1-peer"
  resource_group_name          = azurerm_resource_group.hub_vnet_rg.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  depends_on = [
    azurerm_virtual_network.spoke1,
    azurerm_virtual_network.hub_vnet,
    azurerm_virtual_network_gateway.hub_vnet_gateway
  ]
}

resource "azurerm_virtual_network_peering" "spoke1_hub" {
  name                      = "spoke1-hub-peer"
  resource_group_name       = azurerm_resource_group.spoke1.name
  virtual_network_name      = azurerm_virtual_network.spoke1.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
  depends_on = [
    azurerm_virtual_network.spoke1,
    azurerm_virtual_network.hub_vnet,
    azurerm_virtual_network_gateway.hub_vnet_gateway
  ]
}

## Optional (Connectivity testing)
# resource "azurerm_public_ip" "spoke1" {
#     name                         = "${local.prefix_spoke1}-pip"
#     location            = azurerm_resource_group.spoke1.location
#     resource_group_name = azurerm_resource_group.spoke1.name
#     allocation_method   = "Dynamic"

#     tags = {
#         environment = local.prefix_spoke1
#     }
# }

# resource "azurerm_network_interface" "spoke1" {
#   name                 = "${local.prefix_spoke1}-nic"
#   location             = azurerm_resource_group.spoke1.location
#   resource_group_name  = azurerm_resource_group.spoke1.name
#   enable_ip_forwarding = true

#   ip_configuration {
#     name                          = local.prefix_spoke1
#     subnet_id                     = azurerm_subnet.spoke1_mgmt.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.spoke1.id
#   }
# }

# resource "azurerm_virtual_machine" "spoke1" {
#   name                  = "${local.prefix_spoke1}-vm"
#   location              = azurerm_resource_group.spoke1.location
#   resource_group_name   = azurerm_resource_group.spoke1.name
#   network_interface_ids = [azurerm_network_interface.spoke1.id]
#   vm_size               = var.vmsize

#   storage_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "16.04-LTS"
#     version   = "latest"
#   }

#   storage_os_disk {
#     name              = "myosdisk1"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }

#   os_profile {
#     computer_name  = "${local.prefix_spoke1}-vm"
#     admin_username = var.username
#     admin_password = var.password
#   }

#   os_profile_linux_config {
#     disable_password_authentication = false
#   }

#   tags = {
#     environment = local.prefix_spoke1
#   }
# }

# # Create Network Security Group and rule
# resource "azurerm_network_security_group" "spoke1" {
#     name                = "${local.prefix_spoke1}-nsg"
#     location            = azurerm_resource_group.spoke1.location
#     resource_group_name = azurerm_resource_group.spoke1.name

#     security_rule {
#         name                       = "SSH"
#         priority                   = 1001
#         direction                  = "Inbound"
#         access                     = "Allow"
#         protocol                   = "Tcp"
#         source_port_range          = "*"
#         destination_port_range     = "22"
#         source_address_prefix      = "*"
#         destination_address_prefix = "*"
#     }

#     tags = {
#         environment = "spoke1"
#     }
# }

# resource "azurerm_subnet_network_security_group_association" "spoke1_mgmt" {
#     subnet_id                 = azurerm_subnet.spoke1_mgmt.id
#     network_security_group_id = azurerm_network_security_group.spoke1.id
# }