# Name: variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create multiple Queues

variable "prefix" {
  description = "This prefix will be included in the name of the resources."
}

variable "owner" {
  description = "This owner name tag will be included in the name of the resources."
}

variable "queues" {
  description = "The list of queues to be created."
  type        = map(any)
}

variable "sqs_message_timeout" {
  description = "The length of time during which a message will be unavailable after a message is delivered from the queue."
}
