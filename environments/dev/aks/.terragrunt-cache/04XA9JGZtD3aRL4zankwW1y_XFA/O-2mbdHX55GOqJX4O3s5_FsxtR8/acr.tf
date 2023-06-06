resource "azurerm_container_registry" "main" {
  name                = "${var.application}registry"
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
  #   georeplications {
  #     location                = "East US"
  #     zone_redundancy_enabled = true
  #     tags                    = {}
  #   }
}

# resource "azurerm_role_assignment" "main" {
#   principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
#   role_definition_name             = "AcrPull"
#   scope                            = azurerm_container_registry.main.id
#   skip_service_principal_aad_check = true
# }

resource "azurerm_private_endpoint" "main" {
  name                = "${var.application}registrytoaks"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.aks_sub_id

  private_service_connection {
    name                           = "acrprivateserviceconnection"
    private_connection_resource_id = azurerm_container_registry.main.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "acr-endpoint-zone"
    private_dns_zone_ids = [var.private_zone_id]
  }
}