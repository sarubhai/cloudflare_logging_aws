# Name: variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create the IAM role for the Lambda functions

variable "prefix" {
  description = "This prefix will be included in the name of the resources."
}

variable "owner" {
  description = "This owner name tag will be included in the name of the resources."
}
