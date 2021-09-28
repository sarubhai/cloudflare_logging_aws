# Name: outputs.tf
# Owner: Saurav Mitra
# Description: Outputs the Event Rule ID & ARN

output "event_rule_names" {
  value       = values(aws_cloudwatch_event_rule.log_download_trigger)[*]["id"]
  description = "Event Rule Name."
}

output "event_rule_arns" {
  value       = values(aws_cloudwatch_event_rule.log_download_trigger)[*]["arn"]
  description = "Event Rule ARN."
}
