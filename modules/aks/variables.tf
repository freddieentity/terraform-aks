variable "cluster_name" {
  type = string
}
variable "kubernetes_version" {
  type = string
}
variable "azure_location" {
  type = string
}
variable "resource_group" {
  type = string
}
variable "node_pools" {
  type = map(any)
}
variable "ssh_public_key" {
  type = string
}
variable "windows_admin_username" {
  type = string
}
variable "windows_admin_password" {
  type = string
}
