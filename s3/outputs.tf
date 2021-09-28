# Name: outputs.tf
# Owner: Saurav Mitra
# Description: Outputs the ID, ARN of the S3 Buckets for multiple zones

output "s3_log_bucket_names" {
  value       = values(aws_s3_bucket.log_bucket)[*]["bucket"]
  description = "S3 Log Download Bucket Name."
}

output "s3_log_bucket_ids" {
  value       = values(aws_s3_bucket.log_bucket)[*]["id"]
  description = "S3 Log Download Bucket ID."
}

output "s3_log_bucket_arns" {
  #   value = aws_s3_bucket.log_bucket["zone1"].arn
  value       = values(aws_s3_bucket.log_bucket)[*]["arn"]
  description = "S3 Log Download Bucket ARN."
}
