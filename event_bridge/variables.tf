# Name: variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create EventBridge log download rules/schedules for multiple zones

variable "prefix" {
  description = "This prefix will be included in the name of the resources."
}

variable "owner" {
  description = "This owner name tag will be included in the name of the resources."
}

variable "zones_buckets" {
  description = "The list of zones to trigger cloudflare logs download"
}

variable "generate_parameters_for_log_download_arn" {
  description = "Lambda Function ARN to generate the parameters for log download."
}
