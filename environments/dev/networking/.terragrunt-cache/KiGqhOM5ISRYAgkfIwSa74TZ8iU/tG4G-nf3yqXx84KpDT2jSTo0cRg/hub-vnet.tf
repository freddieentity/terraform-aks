locals {
  prefix_hub         = "hub"
  hub_location       = "eastus"
  hub_resource_group = "hub-vnet-rg"
  shared_key         = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}

resource "azurerm_resource_group" "hub_vnet_rg" {
  name     = local.hub_resource_group
  location = local.hub_location
}

resource "azurerm_virtual_network" "hub_vnet" {
  name                = "${local.prefix_hub}-vnet"
  location            = azurerm_resource_group.hub_vnet_rg.location
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "hub-spoke"
  }
}

resource "azurerm_subnet" "hub_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub_vnet_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.0.255.224/27"]
}

resource "azurerm_subnet" "hub_mgmt" {
  name                 = "Management"
  resource_group_name  = azurerm_resource_group.hub_vnet_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.0.0.64/27"]
}

resource "azurerm_subnet" "hub_dmz" {
  name                 = "DMZ"
  resource_group_name  = azurerm_resource_group.hub_vnet_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.0.0.32/27"]
}

#Virtual Machine
resource "azurerm_network_interface" "hub_nic" {
  name                 = "${local.prefix_hub}-nic"
  location             = azurerm_resource_group.hub_vnet_rg.location
  resource_group_name  = azurerm_resource_group.hub_vnet_rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = local.prefix_hub
    subnet_id                     = azurerm_subnet.hub_mgmt.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = local.prefix_hub
  }
}

resource "azurerm_virtual_machine" "hub_vm" {
  name                  = "${local.prefix_hub}-vm"
  location              = azurerm_resource_group.hub_vnet_rg.location
  resource_group_name   = azurerm_resource_group.hub_vnet_rg.name
  network_interface_ids = [azurerm_network_interface.hub_nic.id]
  vm_size               = var.vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.prefix_hub}-vm"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = local.prefix_hub
  }
}

# Virtual Network Gateway
resource "azurerm_public_ip" "hub_vpn_gateway1_pip" {
  name                = "hub_vpn_gateway1_pip"
  location            = azurerm_resource_group.hub_vnet_rg.location
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "hub_vnet_gateway" {
  name                = "hub-vpn-gateway1"
  location            = azurerm_resource_group.hub_vnet_rg.location
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.hub_vpn_gateway1_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub_gateway.id
  }
  depends_on = [azurerm_public_ip.hub_vpn_gateway1_pip]
}

resource "azurerm_virtual_network_gateway_connection" "hub_onprem_conn" {
  name                = "hub-onprem-conn"
  location            = azurerm_resource_group.hub_vnet_rg.location
  resource_group_name = azurerm_resource_group.hub_vnet_rg.name

  type           = "Vnet2Vnet"
  routing_weight = 1

  virtual_network_gateway_id      = azurerm_virtual_network_gateway.hub_vnet_gateway.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.onprem_vpn_gateway.id

  shared_key = local.shared_key
}

resource "azurerm_virtual_network_gateway_connection" "onprem_hub_conn" {
  name                            = "onprem-hub-conn"
  location                        = azurerm_resource_group.onprem.location
  resource_group_name             = azurerm_resource_group.onprem.name
  type                            = "Vnet2Vnet"
  routing_weight                  = 1
  virtual_network_gateway_id      = azurerm_virtual_network_gateway.onprem_vpn_gateway.id
  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.hub_vnet_gateway.id

  shared_key = local.shared_key
}