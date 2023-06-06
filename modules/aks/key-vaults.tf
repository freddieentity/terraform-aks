resource "azurerm_key_vault" "main" { # Keyvault instace
  name                       = "${var.application}-kv"
  resource_group_name        = var.resource_group
  location                   = var.azure_location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  sku_name                   = "standard"

  enable_rbac_authorization = true
}

data "azurerm_client_config" "current" {}

resource "azurerm_private_endpoint" "kv-endpoint" {
  name                = "${var.application}-pe"
  location            = var.azure_location
  resource_group_name = var.resource_group
  subnet_id           = var.dest_sub_id

  private_service_connection {
    name                           = "${var.application}-privateserviceconnection"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  #   private_dns_zone_group {
  #     name                 = "kv-endpoint-zone"
  #     private_dns_zone_ids = [var.private_zone_id]
  #   }
}

# resource "azurerm_role_assignment" "role-secret-officer" { # Seed the initial administrators to have admin access
#   role_definition_name = "Key Vault Secrets Officer"
#   principal_id         = data.azurerm_client_config.current.object_id
#   scope                = azurerm_key_vault.main.id
# }

# resource "azurerm_key_vault_secret" "database-password" { # Create kv secret
#   name         = var.secret_name
#   value        = var.secret_value
#   key_vault_id = azurerm_key_vault.main.id

#   depends_on   = [azurerm_role_assignment.role-secret-officer]
# }

# resource "azurerm_role_assignment" "role-secret-user" { # Assign the secret with the fine-grained user(principal)
#   role_definition_name = "Key Vault Secrets User"
#   principal_id         = data.azurerm_client_config.current.object_id
#   scope                = "${azurerm_key_vault.main.id}/secrets/${azurerm_key_vault_secret.database-password.name}"
#   // scope                = "/subscriptions/xxxxxxxxx/resourceGroups/kv_rbac_terraform_rg/providers
#   //                         /Microsoft.KeyVault/vaults/demokv01093/secrets/MySecret"
#   // scope                = azurerm_key_vault_secret.database-password.id
# }

