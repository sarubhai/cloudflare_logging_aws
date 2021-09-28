# Name: outputs.tf
# Owner: Saurav Mitra
# Description: Outputs the Elasticsearch Domain ARN & Endpoints for Production & UAT

output "prod_elastic_arn" {
  value       = aws_elasticsearch_domain.elastic_domain["env1"].arn
  description = "Production Elasticsearch Domain ARN."
}

output "prod_elastic_endpoint" {
  value       = aws_elasticsearch_domain.elastic_domain["env1"].endpoint
  description = "Production Elasticsearch Domain Endpoint."
}

output "prod_kibana_endpoint" {
  value       = aws_elasticsearch_domain.elastic_domain["env1"].kibana_endpoint
  description = "Production Kibana Endpoint."
}

output "uat_elastic_arn" {
  value       = aws_elasticsearch_domain.elastic_domain["env2"].arn
  description = "UAT Elasticsearch Domain ARN."
}

output "uat_elastic_endpoint" {
  value       = aws_elasticsearch_domain.elastic_domain["env2"].endpoint
  description = "UAT Elasticsearch Domain Endpoint."
}

output "uat_kibana_endpoint" {
  value       = aws_elasticsearch_domain.elastic_domain["env2"].kibana_endpoint
  description = "UAT Kibana Endpoint."
}
