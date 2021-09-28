# Name: outputs.tf
# Owner: Saurav Mitra
# Description: Outputs the ARN & URL for multiple Queues

output "event_payload_queue_arn" {
  value       = aws_sqs_queue.queue["event_payload_queue"].arn
  description = "Event Payload SQS Queue ARN."
}

output "event_payload_queue_url" {
  value       = aws_sqs_queue.queue["event_payload_queue"].id
  description = "Event Payload SQS Queue URL."
}

output "failed_download_to_s3_queue_arn" {
  value       = aws_sqs_queue.queue["failed_download_to_s3_queue"].arn
  description = "Failed download to S3 SQS Queue ARN."
}

output "failed_download_to_s3_queue_url" {
  value       = aws_sqs_queue.queue["failed_download_to_s3_queue"].id
  description = "Failed download to S3 SQS Queue URL."
}

output "failed_upload_to_elastic_queue_arn" {
  value       = aws_sqs_queue.queue["failed_upload_to_elastic_queue"].arn
  description = "Failed upload to Elasticsearch SQS Queue ARN."
}

output "failed_upload_to_elastic_queue_url" {
  value       = aws_sqs_queue.queue["failed_upload_to_elastic_queue"].id
  description = "Failed upload to Elasticsearch SQS Queue URL."
}
