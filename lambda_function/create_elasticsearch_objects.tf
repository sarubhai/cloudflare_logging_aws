# Name: create_elasticsearch_objects.tf
# Owner: Saurav Mitra
# Description: This terraform config will create initial Elasticsearch objects like Index, Pipelines & Kibana Dashboards

resource "aws_lambda_function" "create_elasticsearch_objects" {
  function_name = "create_elasticsearch_objects"
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
  s3_key    = "lambda_functions/create_elasticsearch_objects/lambda_function.zip"
  handler   = "lambda_function.lambda_handler"

  environment {
    variables = {
      ELASTIC_HOSTNAME_PROD = var.prod_elastic_endpoint
      ELASTIC_HOSTNAME_UAT  = var.uat_elastic_endpoint
      ELASTIC_USERNAME      = var.master_user_name
      ELASTIC_PASSWORD      = var.master_user_password
      S3_CONFIG_BUCKET      = var.s3_config_bucket_name
      S3_CONFIG_FILE        = var.s3_config_file
    }
  }

  tags = {
    Name  = "${var.prefix}-lambda-create_elasticsearch_objects"
    Owner = var.owner
  }
}

resource "aws_lambda_function_event_invoke_config" "lambda_error_handling" {
  function_name          = aws_lambda_function.download_logs_to_s3.function_name
  maximum_retry_attempts = 0
  qualifier              = "$LATEST"
}
