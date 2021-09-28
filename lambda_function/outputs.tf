# Name: outputs.tf
# Owner: Saurav Mitra
# Description: Outputs the lambda Functions ARN

output "generate_parameters_for_log_download_arn" {
  value       = aws_lambda_function.generate_parameters_for_log_download.arn
  description = "Lambda Function ARN to generate the parameters for log download."
}

output "download_logs_to_s3_arn" {
  value       = aws_lambda_function.download_logs_to_s3.arn
  description = "Lambda Function ARN to download logs to S3."
}

output "upload_logs_to_elastic_arn" {
  value       = aws_lambda_function.upload_logs_to_elastic.arn
  description = "Lambda Function ARN to upload logs to Elasticsearch."
}

output "retry_failed_download_logs_to_s3_arn" {
  value       = aws_lambda_function.retry_failed_download_logs_to_s3.arn
  description = "Lambda Function ARN to retry failed download logs to S3."
}

output "retry_failed_upload_logs_to_elastic_arn" {
  value       = aws_lambda_function.retry_failed_upload_logs_to_elastic.arn
  description = "Lambda Function ARN to retry failed upload logs to Elasticsearch."
}

output "create_elasticsearch_objects_arn" {
  value       = aws_lambda_function.create_elasticsearch_objects.arn
  description = "Lambda Function ARN to create initial Elasticsearch objects like Index, Pipelines & Kibana Dashboards."
}