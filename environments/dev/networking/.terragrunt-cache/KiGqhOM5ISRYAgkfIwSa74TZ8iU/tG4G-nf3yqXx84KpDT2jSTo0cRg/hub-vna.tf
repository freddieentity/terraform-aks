locals {
  prefix_hub_nva         = "hub-nva"
  hub_nva_location       = "eastus"
  hub_nva_resource_group = "hub-nva-rg"
}

resource "azurerm_resource_group" "hub_nva_rg" {
  name     = "${local.prefix_hub_nva}-rg"
  location = local.hub_nva_location

  tags = {
    environment = local.prefix_hub_nva
  }
}

# Hub
resource "azurerm_route_table" "hub_gateway" {
  name                          = "hub-gateway-rt"
  location                      = azurerm_resource_group.hub_nva_rg.location
  resource_group_name           = azurerm_resource_group.hub_nva_rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "toHub"
    address_prefix = "10.0.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  route {
    name                   = "toSpoke1"
    address_prefix         = "10.1.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.36"
  }

  route {
    name                   = "toSpoke2"
    address_prefix         = "10.2.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.36"
  }

  tags = {
    environment = local.prefix_hub_nva
  }
}

resource "azurerm_subnet_route_table_association" "hub-gateway-rt-hub-vnet-gateway-subnet" {
  subnet_id      = azurerm_subnet.hub_gateway.id
  route_table_id = azurerm_route_table.hub_gateway.id
  depends_on     = [azurerm_subnet.hub_gateway]
}

# Virtual Machine
resource "azurerm_network_interface" "hub_nva_nic" {
  name                 = "${local.prefix_hub_nva}-nic"
  location             = azurerm_resource_group.hub_nva_rg.location
  resource_group_name  = azurerm_resource_group.hub_nva_rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = local.prefix_hub_nva
    subnet_id                     = azurerm_subnet.hub_dmz.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.36"
  }

  tags = {
    environment = local.prefix_hub_nva
  }
}

resource "azurerm_virtual_machine" "hub_nva_vm" {
  name                  = "${local.prefix_hub_nva}-vm"
  location              = azurerm_resource_group.hub_nva_rg.location
  resource_group_name   = azurerm_resource_group.hub_nva_rg.name
  network_interface_ids = [azurerm_network_interface.hub_nva_nic.id]
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
    computer_name  = "${local.prefix_hub_nva}-vm"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = local.prefix_hub_nva
  }
}

resource "azurerm_virtual_machine_extension" "enable_routes" {
  name                 = "enable-iptables-routes"
  virtual_machine_id   = azurerm_virtual_machine.hub_nva_vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"


  settings = <<SETTINGS
    {
        "fileUris": [
        "https://raw.githubusercontent.com/mspnp/reference-architectures/master/scripts/linux/enable-ip-forwarding.sh"
        ],
        "commandToExecute": "bash enable-ip-forwarding.sh"
    }
SETTINGS

  tags = {
    environment = local.prefix_hub_nva
  }
}

## Spoke 1
resource "azurerm_route_table" "spoke1-rt" {
  name                          = "spoke1-rt"
  location                      = azurerm_resource_group.hub_nva_rg.location
  resource_group_name           = azurerm_resource_group.hub_nva_rg.name
  disable_bgp_route_propagation = false

  route {
    name                   = "toSpoke2"
    address_prefix         = "10.2.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.36"
  }

  route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "vnetlocal"
  }

  tags = {
    environment = local.prefix_hub_nva
  }
}

resource "azurerm_subnet_route_table_association" "spoke1-rt-spoke1-vnet-mgmt" {
  subnet_id      = azurerm_subnet.spoke1_mgmt.id
  route_table_id = azurerm_route_table.spoke1-rt.id
  depends_on     = [azurerm_subnet.spoke1_mgmt]
}

resource "azurerm_subnet_route_table_association" "spoke1-rt-spoke1-vnet-workload" {
  subnet_id      = azurerm_subnet.spoke1_workload.id
  route_table_id = azurerm_route_table.spoke1-rt.id
  depends_on     = [azurerm_subnet.spoke1_workload]
}

# Spoke2
resource "azurerm_route_table" "spoke2-rt" {
  name                          = "spoke2-rt"
  location                      = azurerm_resource_group.hub_nva_rg.location
  resource_group_name           = azurerm_resource_group.hub_nva_rg.name
  disable_bgp_route_propagation = false

  route {
    name                   = "toSpoke1"
    address_prefix         = "10.1.0.0/16"
    next_hop_in_ip_address = "10.0.0.36"
    next_hop_type          = "VirtualAppliance"
  }

  route {
    name           = "default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "vnetlocal"
  }

  tags = {
    environment = local.prefix_hub_nva
  }
}

resource "azurerm_subnet_route_table_association" "spoke2-rt-spoke2-vnet-mgmt" {
  subnet_id      = azurerm_subnet.spoke2_mgmt.id
  route_table_id = azurerm_route_table.spoke2-rt.id
  depends_on     = [azurerm_subnet.spoke2_mgmt]
}

resource "azurerm_subnet_route_table_association" "spoke2-rt-spoke2-vnet-workload" {
  subnet_id      = azurerm_subnet.spoke2_workload.id
  route_table_id = azurerm_route_table.spoke2-rt.id
  depends_on     = [azurerm_subnet.spoke2_workload]
}

