# Name: outputs.tf
# Owner: Saurav Mitra
# Description: Outputs the ID, ARN of the S3 Codebase Bucket along with the Uploaded files

output "s3_code_bucket_name" {
  value       = aws_s3_bucket.code_bucket.bucket
  description = "S3 Lambda Code Bucket Name."
}

output "s3_code_bucket_id" {
  value       = aws_s3_bucket.code_bucket.id
  description = "S3 Lambda Code Bucket ID."
}

output "s3_code_bucket_arn" {
  value       = aws_s3_bucket.code_bucket.arn
  description = "S3 Lambda Code Bucket ARN."
}

output "code_files" {
  value       = fileset(path.module, "**/*.zip")
  description = "Lambda Code Files."
}
