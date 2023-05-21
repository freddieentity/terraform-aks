cluster_name       = "tinnt26"
kubernetes_version = "1.26.0"
azure_location     = "eastus2"
resource_group     = "tinnt26"

node_pools = {
  spot = {
    name            = "spot"
    vm_size         = "Standard_DS2_v2"
    node_count      = 1
    priority        = "Spot"
    eviction_policy = "Delete"
    spot_max_price  = 0.5 # note: this is the "maximum" price
    node_labels = {
      "kubernetes.azure.com/scalesetpriority" = "spot"
    }
    node_taints = [
      "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
    ]
  }
}
ssh_public_key         = "~/.ssh/id_rsa.pub"
windows_admin_username = "azureuser"
windows_admin_password = "P@ssw0rd123456"