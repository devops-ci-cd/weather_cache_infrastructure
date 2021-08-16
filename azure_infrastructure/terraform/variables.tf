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
  default = "__id__"
}

variable "client_secret" {
  description = "Service principal client password"
  default = "__password__"
}

variable "tenant_id" {
  description = "Service principal tenant id"
  default = "__tenant_id__"
}

variable "administrator_login" {
  default = "__administrator_login__"
}

variable "administrator_password" {
  default = "__administrator_password__"
}

variable "storage_account_name" {
  default = "__terraformstorageaccount__"  
}

variable "storage_account_access_key" {
  default = "__storagekey__"
}