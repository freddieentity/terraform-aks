module "aks" {
  source = "./modules/aks"

  azure_location = var.azure_location

  cluster_name           = var.cluster_name
  kubernetes_version     = var.kubernetes_version
  resource_group         = var.resource_group
  node_pools             = var.node_pools
  ssh_public_key         = var.ssh_public_key
  windows_admin_username = var.windows_admin_username
  windows_admin_password = var.windows_admin_password
}