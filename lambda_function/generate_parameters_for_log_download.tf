# Name: generate_parameters_for_log_download.tf
# Owner: Saurav Mitra
# Description: This terraform config will create a Lambda Function to generate the parameters for log download

data "aws_region" "current" {}

resource "aws_lambda_function" "generate_parameters_for_log_download" {
  function_name = "generate_parameters_for_log_download"
  description   = "Set Date parameters required to download Cloudflare Logs"
  memory_size   = var.lambda_memory
  timeout       = var.lambda_timeout
  runtime       = var.lambda_runtime
  role          = var.lambda_iam_role_arn

  vpc_config {
    subnet_ids         = var.private_subnet_id
    security_group_ids = [var.lambda_sg_id]
  }

  layers    = [var.requests_lambda_layer_arn, var.elasticsearch_lambda_layer_arn]
  s3_bucket = var.s3_code_bucket_name
  s3_key    = "lambda_functions/generate_parameters_for_log_download/lambda_function.zip"
  handler   = "lambda_function.lambda_handler"

  environment {
    variables = {
      ELASTIC_HOSTNAME_PROD = var.prod_elastic_endpoint
      ELASTIC_HOSTNAME_UAT  = var.uat_elastic_endpoint
      ELASTIC_USERNAME      = var.master_user_name
      ELASTIC_PASSWORD      = var.master_user_password
      SQS_ENDPOINT_URL      = "https://sqs.${data.aws_region.current.name}.amazonaws.com"
      SQS_QUEUE_URL         = var.event_payload_queue_url
    }
  }

  tags = {
    Name  = "${var.prefix}-lambda-generate_parameters_for_log_download"
    Owner = var.owner
  }
}

resource "aws_lambda_function_event_invoke_config" "lambda_error_handling1" {
  function_name          = aws_lambda_function.generate_parameters_for_log_download.function_name
  maximum_retry_attempts = 0
  qualifier              = "$LATEST"
}
