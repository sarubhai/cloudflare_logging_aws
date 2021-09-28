# Name: outputs.tf
# Owner: Saurav Mitra
# Description: Outputs the Securtiy Group IDs for Lambda functions & Elasticsearch

output "lambda_sg_id" {
  value       = aws_security_group.lambda_sg.id
  description = "Security Group for Lambda Functions."
}

output "elastic_sg_id" {
  value       = aws_security_group.elastic_sg.id
  description = "Security Group for Elasticsearch Domains."
}
