resource "azurerm_resource_group" "main" {
  name     = var.resource_group
  location = var.azure_location
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = var.cluster_name
  node_resource_group = azurerm_resource_group.main.name

  #   oidc_issuer_enabled = true

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = "30"
  }



  identity {
    type = "SystemAssigned"
  }

  #   service_principal {
  #     client_id     = data.azurerm_key_vault_secret.spn_id.value
  #     client_secret = data.azurerm_key_vault_secret.spn_secret.value
  #   }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "calico"
  }

  azure_policy_enabled = true

  #   oms_agent {
  #     log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  #   }

  windows_profile {
    admin_username = var.windows_admin_username
    admin_password = var.windows_admin_password
  }

  linux_profile {
    admin_username = var.windows_admin_username
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }
  # role_based_access_control_enabled = true
  # azure_active_directory_role_based_access_control {
  #   managed                = true
  #   admin_group_object_ids = [azuread_group.aks_administrators.id]
  # }


  tags = {
    Environment = "Demo"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "main" {
  for_each = var.node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  priority              = each.value.priority
  eviction_policy       = each.value.eviction_policy
  spot_max_price        = each.value.spot_max_price # note: this is the "maximum" price
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints
}
