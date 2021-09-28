# Name: download_logs_to_s3.tf
# Owner: Saurav Mitra
# Description: This terraform config will create a Lambda Function to download cloudflare logs to S3 buckets

resource "aws_lambda_function" "download_logs_to_s3" {
  function_name = "download_logs_to_s3"
  description   = "Download Cloudflare logs to S3"
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
  s3_key    = "lambda_functions/download_logs_to_s3/lambda_function.zip"
  handler   = "lambda_function.lambda_handler"

  environment {
    variables = {
      ELASTIC_HOSTNAME_PROD = var.prod_elastic_endpoint
      ELASTIC_HOSTNAME_UAT  = var.uat_elastic_endpoint
      ELASTIC_USERNAME      = var.master_user_name
      ELASTIC_PASSWORD      = var.master_user_password
      CLOUDFLARE_URL        = var.cloudflare_url
    }
  }

  dead_letter_config {
    target_arn = var.failed_download_to_s3_queue_arn
  }

  tags = {
    Name  = "${var.prefix}-lambda-download_logs_to_s3"
    Owner = var.owner
  }
}

resource "aws_lambda_function_event_invoke_config" "lambda_error_handling2" {
  function_name          = aws_lambda_function.download_logs_to_s3.function_name
  maximum_retry_attempts = 0
  qualifier              = "$LATEST"
}

resource "aws_lambda_event_source_mapping" "event_payload_queue" {
  event_source_arn = var.event_payload_queue_arn
  function_name    = aws_lambda_function.download_logs_to_s3.arn
  batch_size       = 1
  enabled          = true
}
