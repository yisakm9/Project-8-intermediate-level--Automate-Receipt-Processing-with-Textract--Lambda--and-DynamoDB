output "lambda_execution_role_arn" {
  description = "The ARN of the IAM role for the Lambda function."
  value       = aws_iam_role.lambda_execution_role.arn
}
output "presigned_url_lambda_role_arn" {
  description = "The ARN of the IAM role for the presigned URL Lambda function."
  value       = aws_iam_role.presigned_url_lambda_role.arn
}