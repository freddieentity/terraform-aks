# data "azuread_client_config" "current" {}

# resource "azuread_application" "app" {
#   display_name = "appsp"
# }

# resource "azuread_service_principal" "default" {
#   application_id = azuread_application.app.application_id
# }

# resource "azuread_service_principal_password" "default" {
#   service_principal_id = azuread_service_principal.default.id
# }

# resource "azuread_application_federated_identity_credential" "app" {
#   application_object_id = azuread_application.app.object_id
#   display_name          = "fed-identity-app"
#   description           = "The federated identity used to federate K8s with Azure AD"
#   audiences             = ["api://AzureADTokenExchange"]
#   issuer                = azurerm_kubernetes_cluster.main.oidc_issuer_url
#   subject               = "system:serviceaccount:azwins:azwisa"
# }

# resource "azuread_group" "aks_administrators" {
#   display_name     = "${azurerm_resource_group.main.name}-aks-administrators"
#   security_enabled = true
#   owners           = [data.azuread_client_config.current.object_id]
#   members = [
#     data.azuread_client_config.current.object_id, # The host that run this Terraform
#     azuread_service_principal.default.object_id, # The newly created above SPN
#   ]
#   description      = "Azure AKS Kubernetes administrators of cluster."
# }
