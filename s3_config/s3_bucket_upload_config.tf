# Name: s3_bucket_upload_config.tf
# Owner: Saurav Mitra
# Description: This terraform config will create a S3 bucket & upload bucket-env mapping config

data "aws_region" "current" {}

# Create a bucket
resource "aws_s3_bucket" "config_bucket" {
  bucket = lower("${var.prefix}-${var.owner}-${data.aws_region.current.name}-config")
  acl    = "private"

  tags = {
    Name  = "${var.prefix}-config"
    Owner = var.owner
  }
}

# Upload Config Files
# resource "aws_s3_bucket_object" "configfile" {
#   bucket = aws_s3_bucket.config_bucket.id
#   acl    = "private"
#   key    = "bucket_env_map.json"
#   source = "${path.module}/bucket_env_map.json"
#   etag   = filemd5("${path.module}/bucket_env_map.json")
# }

resource "aws_s3_bucket_object" "configfiles" {
  for_each = fileset(path.module, "**/*.*")

  bucket = aws_s3_bucket.config_bucket.id
  acl    = "private"
  key    = each.value
  source = "${path.module}/${each.value}"
  etag   = filemd5("${path.module}/${each.value}")
}