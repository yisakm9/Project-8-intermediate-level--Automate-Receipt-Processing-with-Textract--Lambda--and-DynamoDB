output "function_arn" {
  description = "The ARN of the presigned URL Lambda function."
  value       = aws_lambda_function.presigned_url_generator.arn
}

output "function_invoke_arn" {
  description = "The Invoke ARN of the presigned URL Lambda function."
  value       = aws_lambda_function.presigned_url_generator.invoke_arn
}