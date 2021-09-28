# Name: variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create a S3 bucket & upload bucket-env mapping config

variable "prefix" {
  description = "This prefix will be included in the name of the resources."
}

variable "owner" {
  description = "This owner name tag will be included in the name of the resources."
}
