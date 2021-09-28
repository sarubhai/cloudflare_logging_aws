# outputs.tf
# Owner: Saurav Mitra
# Description: Outputs the relevant resources ID, ARN, URL values
# https://www.terraform.io/docs/configuration/outputs.html

# VPC & Subnet
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The VPC ID."
}

output "VPC-public_subnet_id" {
  value       = module.vpc.public_subnet_id
  description = "The public subnets ID."
}

output "private_subnet_id" {
  value       = module.vpc.private_subnet_id
  description = "The private subnets ID."
}


# SQS
output "event_payload_queue_url" {
  value       = module.sqs.event_payload_queue_url
  description = "Event Payload SQS Queue URL."
}

output "failed_download_to_s3_queue_url" {
  value       = module.sqs.failed_download_to_s3_queue_url
  description = "Failed download to S3 SQS Queue URL."
}

output "failed_upload_to_elastic_queue_url" {
  value       = module.sqs.failed_upload_to_elastic_queue_url
  description = "Failed upload to Elasticsearch SQS Queue URL."
}


# Elasticsearch
output "prod_elastic_arn" {
  value       = module.elasticsearch.prod_elastic_arn
  description = "Production Elasticsearch Domain ARN."
}

output "prod_elastic_endpoint" {
  value       = module.elasticsearch.prod_elastic_endpoint
  description = "Production Elasticsearch Domain Endpoint."
}

output "prod_kibana_endpoint" {
  value       = module.elasticsearch.prod_kibana_endpoint
  description = "Production Kibana Endpoint."
}

output "uat_elastic_arn" {
  value       = module.elasticsearch.uat_elastic_arn
  description = "UAT Elasticsearch Domain ARN."
}

output "uat_elastic_endpoint" {
  value       = module.elasticsearch.uat_elastic_endpoint
  description = "UAT Elasticsearch Domain Endpoint."
}

output "uat_kibana_endpoint" {
  value       = module.elasticsearch.uat_kibana_endpoint
  description = "UAT Kibana Endpoint."
}



# S3 Config
output "s3_config_bucket_name" {
  value       = module.s3_config.s3_config_bucket_name
  description = "S3 Config Bucket Name."
}

output "s3_config_file" {
  value       = module.s3_config.s3_config_file
  description = "Bucket-Env Mapping Config File."
}

# S3 Lambda Code
output "s3_code_bucket_name" {
  value       = module.s3_codebase.s3_code_bucket_name
  description = "S3 Lambda Code Bucket Name."
}

output "s3_codebase_files" {
  value       = module.s3_codebase.code_files
  description = "Lambda Code files."
}

# Lambda Functions
output "generate_parameters_for_log_download_arn" {
  value       = module.lambda_function.generate_parameters_for_log_download_arn
  description = "Lambda Function ARN to generate the parameters for log download."
}

output "download_logs_to_s3_arn" {
  value       = module.lambda_function.download_logs_to_s3_arn
  description = "Lambda Function ARN to download logs to S3."
}

output "upload_logs_to_elastic_arn" {
  value       = module.lambda_function.upload_logs_to_elastic_arn
  description = "Lambda Function ARN to upload logs to Elasticsearch."
}

output "retry_failed_download_logs_to_s3_arn" {
  value       = module.lambda_function.retry_failed_download_logs_to_s3_arn
  description = "Lambda Function ARN to retry failed download logs to S3."
}

output "retry_failed_upload_logs_to_elastic_arn" {
  value       = module.lambda_function.retry_failed_upload_logs_to_elastic_arn
  description = "Lambda Function ARN to retry failed upload logs to Elasticsearch."
}

output "create_elasticsearch_objects_arn" {
  value       = module.lambda_function.create_elasticsearch_objects_arn
  description = "Lambda Function ARN to create initial Elasticsearch objects like Index, Pipelines & Kibana Dashboards."
}



# S3 Log Download
output "s3_log_bucket_names" {
  value       = module.s3.s3_log_bucket_names
  description = "S3 Log Download Bucket Name."
}

output "s3_log_bucket_ids" {
  value       = module.s3.s3_log_bucket_ids
  description = "S3 Log Download Bucket ID."
}

output "s3_log_bucket_arns" {
  value       = module.s3.s3_log_bucket_arns
  description = "S3 Log Download Bucket ARN."
}

# Event Bridge Rules
output "event_rule_names" {
  value       = module.event_bridge.event_rule_names
  description = "Event Rule Name."
}

output "event_rule_arns" {
  value       = module.event_bridge.event_rule_arns
  description = "Event Rule ARN."
}



# OPTIONAL TO CONNECT TO VPC USING VPN
# OpenVPN Access Server
output "openvpn_access_server_ip" {
  value       = module.openvpn.openvpn_access_server_ip
  description = "OpenVPN Access Server IP."
}
