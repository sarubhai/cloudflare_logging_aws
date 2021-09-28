# Name: variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create Lambda Layers

variable "s3_code_bucket_name" {
  description = "S3 Lambda Code Bucket Name."
}

variable "requests_lambda_layer_s3key" {
  description = "The requests lambda layer s3 filename/key."
}

variable "elasticsearch_lambda_layer_s3key" {
  description = "The elasticsearch lambda layer s3 filename/key."
}

variable "lambda_layer_runtimes" {
  description = "Lambda layer Runtime."
}

variable "lambda_layer_license" {
  description = "Lambda layer License."
}
