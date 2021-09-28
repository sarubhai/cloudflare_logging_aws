# Name: variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create S3 buckets with Life Cycle Rules for Cloudflare logs downloads for multiple zones

variable "prefix" {
  description = "This prefix will be included in the name of the resources."
}

variable "owner" {
  description = "This owner name tag will be included in the name of the resources."
}

variable "zones_buckets" {
  description = "The list of zones to trigger cloudflare logs download"
}

variable "s3_log_expiration" {
  description = "The retention duration in days for objects in S3 buckets."
}

variable "upload_logs_to_elastic_arn" {
  description = "Lambda Function ARN to upload logs to Elasticsearch."
}
