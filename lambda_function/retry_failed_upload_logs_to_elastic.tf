# Name: retry_failed_upload_logs_to_elastic.tf
# Owner: Saurav Mitra
# Description: This terraform config will create a Lambda Function to retry failed upload cloudflare logs from S3 buckets to Elasticsearch

resource "aws_lambda_function" "retry_failed_upload_logs_to_elastic" {
  function_name = "retry_failed_upload_logs_to_elastic"
  description   = "Retry Failed Upload Cloudflare logs from S3 to Elastic"
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
  s3_key    = "lambda_functions/retry_failed_upload_logs_to_elastic/lambda_function.zip"
  handler   = "lambda_function.lambda_handler"

  environment {
    variables = {
      ELASTIC_HOSTNAME_PROD = var.prod_elastic_endpoint
      ELASTIC_HOSTNAME_UAT  = var.uat_elastic_endpoint
      ELASTIC_USERNAME      = var.master_user_name
      ELASTIC_PASSWORD      = var.master_user_password
    }
  }

  tags = {
    Name  = "${var.prefix}-lambda-retry_failed_upload_logs_to_elastic"
    Owner = var.owner
  }
}

resource "aws_lambda_function_event_invoke_config" "lambda_error_handling5" {
  function_name          = aws_lambda_function.retry_failed_upload_logs_to_elastic.function_name
  maximum_retry_attempts = 0
  qualifier              = "$LATEST"
}

resource "aws_lambda_event_source_mapping" "failed_upload_to_elastic_queue" {
  event_source_arn = var.failed_upload_to_elastic_queue_arn
  function_name    = aws_lambda_function.retry_failed_upload_logs_to_elastic.arn
  batch_size       = 1
  enabled          = true
}
