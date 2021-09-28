# Name: outputs.tf
# Owner: Saurav Mitra
# Description: Outputs the Lambda IAM role ID & ARN

output "lambda_iam_role_id" {
  value       = aws_iam_role.lambda_role.id
  description = "IAM Role ID for Lambda Functions."
}

output "lambda_iam_role_arn" {
  value       = aws_iam_role.lambda_role.arn
  description = "IAM Role ARN for Lambda Functions."
}
