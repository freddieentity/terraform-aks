include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/aks"
}

# Acess this using syntax local.common.locals.tags
locals {
  common = read_terragrunt_config(find_in_parent_folders("common.hcl"))
}

// dependency "vpc" {
//   config_path = "../vpc"

//   # Must have when execute plan due to variables deps. The variables must have a desired type in the module
//   mock_outputs = {
//     public_subnet_ids  = ["public-subnet-1234", "public-subnet-6789"]
//     private_subnet_ids = ["private-subnet-1234", "private-subnet-6789"]
//   }
//   mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "show"]
// }

inputs = {
  application        = "tinnt26app"
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
}