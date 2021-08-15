
# variable definition and default values

variable "prefix" {
  type = string
  default = "polyarush"
  description = "The prefix used for all resources"
}

variable "location" {
  description = "The Azure location where all resources should be created"
  default = "West Europe"
}

variable "rg" {
  description = "Resource group where all resources should be created"
  default = "EPM-RDSP"
}

variable "subscription_id" {
  description = "Service principal subscription id"
  default = "__subscription_id__"
}

variable "client_id" {
  description = "Service principal client id"
  value = "__id__"
}

variable "client_secret" {
  description = "Service principal client password"
  value = "__password__"
}

variable "tenant_id" {
  description = "Service principal tenant id"
  value = "__tenant_id__"
}

variable "storage_access_key" {
  value = "__storagekey__"
}

variable "terraform_storage_account" {
  value = "__terraformstorageaccount__"
}

variable "administrator_login" {
  value = "__administrator_login__"
}

variable "administrator_password" {
  value = "__administrator_password__"
}
