# Configure the Azure provider
terraform {
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.30.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  # default_tags {
  #   tags = {
  #     ApplicationName = "Azure-IaC"
  #     Creator         = "TinNT26"
  #     OwnerService    = "CuongNV61"
  #     ProjectID       = "GHSPOC2019"
  #     CreatedBy      = "Terraform"
  #   }
  # }
}



# data "azurerm_kubernetes_cluster" "main" {
#   name                = azurerm_kubernetes_cluster.main.name
#   resource_group_name = azurerm_resource_group.spoke_aks.name
# }


# provider "helm" {
#   kubernetes {
#     host                   = data.azurerm_kubernetes_cluster.main.kube_config.0.host
#     client_certificate     = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
#     client_key             = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.client_key)
#     cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
#   }
# }