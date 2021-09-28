# Name: s3_bucket_upload_code.tf
# Owner: Saurav Mitra
# Description: This terraform config will create a S3 bucket & upload lambda layer & function codes

data "aws_region" "current" {}

# Create a bucket
resource "aws_s3_bucket" "code_bucket" {
  bucket = lower("${var.prefix}-${var.owner}--${data.aws_region.current.name}-lambda-codebase")
  acl    = "private"

  tags = {
    Name  = "${var.prefix}-${var.owner}--${data.aws_region.current.name}-lambda-codebase"
    Owner = var.owner
  }
}

# Upload Code Files
resource "aws_s3_bucket_object" "codefiles" {
  for_each = fileset(path.module, "**/*.zip")

  bucket = aws_s3_bucket.code_bucket.id
  acl    = "private"
  key    = each.value
  source = "${path.module}/${each.value}"
  etag   = filemd5("${path.module}/${each.value}")
}
