# Name: layers.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Lambda Layers

# Create Python Requests Layer
# https://github.com/psf/requests/tree/master/requests
resource "aws_lambda_layer_version" "requests_layer" {
  layer_name          = "py_requests_lambda_layer"
  description         = "Python Requests Library Layer"
  s3_bucket           = var.s3_code_bucket_name
  s3_key              = var.requests_lambda_layer_s3key
  compatible_runtimes = var.lambda_layer_runtimes
  license_info        = var.lambda_layer_license
}

# Create Python Elasticsearch Layer
# https://github.com/elastic/elasticsearch-py/tree/master/elasticsearch
resource "aws_lambda_layer_version" "elasticsearch_layer" {
  layer_name          = "py_elasticsearch_lambda_layer"
  description         = "Python Elasticsearch Library Layer"
  s3_bucket           = var.s3_code_bucket_name
  s3_key              = var.elasticsearch_lambda_layer_s3key
  compatible_runtimes = var.lambda_layer_runtimes
  license_info        = var.lambda_layer_license
}
