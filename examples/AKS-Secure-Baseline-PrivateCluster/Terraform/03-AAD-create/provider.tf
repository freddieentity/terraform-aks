# Update the variables in the BACKEND block to refrence the
# storage account created out of band for TF statemanagement.

terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }

  backend "local" {
    # resource_group_name  = ""   # Partial configuration, provided during "terraform init"
    # storage_account_name = ""   # Partial configuration, provided during "terraform init"
    # container_name       = ""   # Partial configuration, provided during "terraform init"
    # key = "aad"
  }

}

provider "azurerm" {
  features {}
}

provider "azuread" {}