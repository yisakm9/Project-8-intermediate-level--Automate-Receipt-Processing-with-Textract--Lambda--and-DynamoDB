output "api_endpoint" {
  description = "The base URL for the deployed API."
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "api_id" {
  description = "The ID of the API Gateway."
  value       = aws_apigatewayv2_api.http_api.id
}