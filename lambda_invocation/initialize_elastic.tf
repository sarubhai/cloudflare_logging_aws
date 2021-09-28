# Name: initialize_elastic.tf
# Owner: Saurav Mitra
# Description: This terraform config will execute create_elasticsearch_objects lambda function for Production & UAT elastic domains

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# Invoke Lambda Function
data "aws_lambda_invocation" "example" {
  for_each = var.domain_suffix

  function_name = "create_elasticsearch_objects"

  input = <<JSON
{
  "zone_env": "${each.value}"
}
JSON
}
