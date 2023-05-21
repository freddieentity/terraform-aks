variable "project_id" {
  type = string
}

variable "application" {
  type = string
}

variable "azure_location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnetcidr" {
  type = list(any)
}

variable "subnetcidr" {
  type = list(any)
}

