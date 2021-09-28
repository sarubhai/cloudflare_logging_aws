# Name: outputs.tf
# Owner: Saurav Mitra
# Description: Outputs the Lambda Layers ARN

output "requests_lambda_layer_arn" {
  value       = aws_lambda_layer_version.requests_layer.arn
  description = "Lambda layer ARN for python library Requests."
}

output "elasticsearch_lambda_layer_arn" {
  value       = aws_lambda_layer_version.elasticsearch_layer.arn
  description = "Lambda layer ARN for python library Elasticsearch."
}
