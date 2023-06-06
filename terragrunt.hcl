remote_state {
  backend = "local"
  // backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    // resource_group_name  = "TinNT26"
    // storage_account_name = "tinnt26remotestate"
    // container_name       = "${path_relative_to_include()}"
    // key                  = "terraform.tfstate"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
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
EOF
}