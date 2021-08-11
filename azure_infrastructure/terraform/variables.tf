
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