locals {
  onprem-location       = "eastus"
  onprem-resource-group = "onprem-vnet-rg"
  prefix-onprem         = "onprem"
}

resource "azurerm_resource_group" "onprem" {
  name     = local.onprem-resource-group
  location = local.onprem-location
}

resource "azurerm_virtual_network" "onprem" {
  name                = "onprem-vnet"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name
  address_space       = ["192.168.0.0/16"]

  tags = {
    environment = local.prefix-onprem
  }
}

resource "azurerm_subnet" "onprem_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.onprem.name
  virtual_network_name = azurerm_virtual_network.onprem.name
  address_prefixes     = ["192.168.255.224/27"]
}

resource "azurerm_subnet" "onprem_mgmt" {
  name                 = "Management"
  resource_group_name  = azurerm_resource_group.onprem.name
  virtual_network_name = azurerm_virtual_network.onprem.name
  address_prefixes     = ["192.168.1.128/25"]
}

resource "azurerm_public_ip" "onprem_vpn_gateway1" {
  name                = "${local.prefix-onprem}-vpn-gateway1-pip"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "onprem_vpn_gateway" {
  name                = "onprem-vpn-gateway1"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.onprem_vpn_gateway1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.onprem_gateway.id
  }
  depends_on = [azurerm_public_ip.onprem_vpn_gateway1]

}


## Optional(Connectivity testing)
# resource "azurerm_public_ip" "onprem" {
#     name                         = "${local.prefix-onprem}-pip"
#     location            = azurerm_resource_group.onprem.location
#     resource_group_name = azurerm_resource_group.onprem.name
#     allocation_method   = "Dynamic"

#     tags = {
#         environment = local.prefix-onprem
#     }
# }

# resource "azurerm_network_interface" "onprem" {
#     name                 = "${local.prefix-onprem}-nic"
#     location             = azurerm_resource_group.onprem.location
#     resource_group_name  = azurerm_resource_group.onprem.name
#     enable_ip_forwarding = true

#     ip_configuration {
#     name                          = local.prefix-onprem
#     subnet_id                     = azurerm_subnet.onprem_mgmt.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.onprem.id
#     }
# }

# resource "azurerm_virtual_machine" "onprem" {
#     name                  = "${local.prefix-onprem}-vm"
#     location              = azurerm_resource_group.onprem.location
#     resource_group_name   = azurerm_resource_group.onprem.name
#     network_interface_ids = [azurerm_network_interface.onprem.id]
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
#     computer_name  = "${local.prefix-onprem}-vm"
#     admin_username = var.username
#     admin_password = var.password
#     }

#     os_profile_linux_config {
#     disable_password_authentication = false
#     }

#     tags = {
#     environment = local.prefix-onprem
#     }
# }

# # Create Network Security Group and rule
# resource "azurerm_network_security_group" "onprem" {
#     name                = "${local.prefix-onprem}-nsg"
#     location            = azurerm_resource_group.onprem.location
#     resource_group_name = azurerm_resource_group.onprem.name

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
#         environment = "onprem"
#     }
# }

# resource "azurerm_subnet_network_security_group_association" "mgmt" {
#     subnet_id                 = azurerm_subnet.onprem_mgmt.id
#     network_security_group_id = azurerm_network_security_group.onprem.id
# }