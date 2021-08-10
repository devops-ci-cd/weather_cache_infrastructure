
# variable definition and default values

variable "prefix" {
  type = string
  default = "polyarush"
  description = "The prefix used for all resources in this example"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
  default = "westeurope"
}