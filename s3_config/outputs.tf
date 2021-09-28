# Name: outputs.tf
# Owner: Saurav Mitra
# Description: Outputs the ID, ARN of the S3 Config Bucket along with the Uploaded config file

output "s3_config_bucket_name" {
  value       = aws_s3_bucket.config_bucket.bucket
  description = "S3 Config Bucket Name."
}

output "s3_config_bucket_id" {
  value       = aws_s3_bucket.config_bucket.id
  description = "S3 Config Bucket ID."
}

output "s3_config_bucket_arn" {
  value       = aws_s3_bucket.config_bucket.arn
  description = "S3 Config Bucket ARN."
}

output "s3_config_file" {
  value       = "bucket_env_map.json"
  description = "Bucket-Env Mapping Config File."
}
