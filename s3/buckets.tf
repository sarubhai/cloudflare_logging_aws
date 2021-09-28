# Name: buckets.tf
# Owner: Saurav Mitra
# Description: This terraform config will create S3 buckets with Life Cycle Rules for Cloudflare logs downloads for multiple zones

resource "aws_s3_bucket" "log_bucket" {
  for_each = var.zones_buckets

  bucket        = each.value["s3_bucket"]
  acl           = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        # kms_master_key_id = aws_kms_key.mykey.arn
      }
    }
  }

  lifecycle_rule {
    enabled = true
    expiration {
      days = var.s3_log_expiration
    }
  }

  tags = {
    Name    = each.value["s3_bucket"]
    Project = var.prefix
    Owner   = var.owner
  }
}

resource "aws_lambda_permission" "allow_bucket" {
  for_each = var.zones_buckets

  statement_id  = "AllowExecutionFromS3Bucket-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = var.upload_logs_to_elastic_arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.log_bucket[each.key].arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  for_each = var.zones_buckets

  bucket = aws_s3_bucket.log_bucket[each.key].id

  lambda_function {
    lambda_function_arn = var.upload_logs_to_elastic_arn
    events              = ["s3:ObjectCreated:*"]
    # filter_prefix       = "CloudflareLogs/"
    # filter_suffix       = ".json"
  }

  # The Bucket Notification depends on the invoke lambda function permission
  depends_on = [aws_lambda_permission.allow_bucket]
}
