# Name: variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create Lambda Functions
variable "prefix" {
  description = "This prefix will be included in the name of the resources."
}

variable "owner" {
  description = "This owner name tag will be included in the name of the resources."
}

variable "lambda_runtime" {
  description = "Lambda function Runtime."
}

variable "lambda_memory" {
  description = "Lambda function memeory in MB."
}

variable "lambda_timeout" {
  description = "The time out duration in seconds for Lambda function execution."
}

variable "lambda_iam_role_arn" {
  description = "IAM Role ARN for Lambda Functions."
}

variable "private_subnet_id" {
  description = "The private subnets ID."
}

variable "lambda_sg_id" {
  description = "Security Group for Lambda Functions."
}

variable "requests_lambda_layer_arn" {
  description = "Lambda layer ARN for python library Requests."
}

variable "elasticsearch_lambda_layer_arn" {
  description = "Lambda layer ARN for python library Elasticsearch."
}

variable "s3_code_bucket_name" {
  description = "S3 Lambda Code Bucket Name."
}

variable "prod_elastic_endpoint" {
  description = "Production Elasticsearch Domain Endpoint."
}

variable "uat_elastic_endpoint" {
  description = "UAT Elasticsearch Domain Endpoint."
}

variable "master_user_name" {
  description = "The Master Username of Elasticsearch."
}

variable "master_user_password" {
  description = "The Master Password Elasticsearch."
}

variable "event_payload_queue_url" {
  description = "Event Payload SQS Queue URL."
}

variable "cloudflare_url" {
  description = "Cloudflare API endpoint for zones log."
}

variable "event_payload_queue_arn" {
  description = "Event Payload SQS Queue ARN."
}

variable "failed_download_to_s3_queue_arn" {
  description = "Failed download to S3 SQS Queue ARN."
}

variable "failed_upload_to_elastic_queue_arn" {
  description = "Failed upload to Elasticsearch SQS Queue ARN."
}

variable "s3_config_bucket_name" {
  description = "S3 Config Bucket Name."
}

variable "s3_config_file" {
  description = "Bucket-Env Mapping Config File."
}
