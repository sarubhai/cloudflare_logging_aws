# Name: rules.tf
# Owner: Saurav Mitra
# Description: This terraform config will create EventBridge log download rules/schedules for multiple zones

resource "aws_cloudwatch_event_rule" "log_download_trigger" {
  for_each = var.zones_buckets

  name                = each.key
  description         = "Schedule Log Download Trigger for ${each.key}"
  schedule_expression = "rate(${each.value["rate"]} minutes)"
  is_enabled          = true

  tags = {
    Name    = each.key
    Project = var.prefix
    Owner   = var.owner
  }
}

resource "aws_cloudwatch_event_target" "target_lambda" {
  for_each = var.zones_buckets

  arn   = var.generate_parameters_for_log_download_arn
  rule  = aws_cloudwatch_event_rule.log_download_trigger[each.key].id
  input = "{ \"zone_id\": \"${each.key}\", \"s3_bucket\": \"${each.value["s3_bucket"]}\", \"env\": \"${each.value["env"]}\", \"rate\": ${each.value["rate"]} }"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_function" {
  for_each = var.zones_buckets

  action        = "lambda:InvokeFunction"
  function_name = var.generate_parameters_for_log_download_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.log_download_trigger[each.key].arn
}
