
# # Deploy DNS Private Zone for ACR

resource "azurerm_private_dns_zone" "azurecr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "lz_acr" {
  name                  = "lz_to_acrs"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.azurecr.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

# output "acr_private_zone_id" {
#   value = azurerm_private_dns_zone.azurecr.id
# }

# output "acr_private_zone_name" {
#   value = azurerm_private_dns_zone.azurecr.name
# }

# # Deploy DNS Private Zone for KV

resource "azurerm_private_dns_zone" "vaultcore" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "lz_kv" {
  name                  = "lz_to_kvs"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.vaultcore.name
  virtual_network_id    = azurerm_virtual_network.main.id
}

# output "kv_private_zone_id" {
#   value = azurerm_private_dns_zone.vaultcore.id
# }

# output "kv_private_zone_name" {
#   value = azurerm_private_dns_zone.vaultcore.name
# }