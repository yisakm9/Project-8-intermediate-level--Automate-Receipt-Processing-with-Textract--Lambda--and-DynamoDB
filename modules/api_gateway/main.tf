# resource.aws_apigatewayv2_api "http_api": Creates the main HTTP API gateway.
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-api-${var.environment}"
  protocol_type = "HTTP"
  
  # Enable CORS to allow our frontend, served from a different domain, to call this API.
  cors_configuration {
    allow_origins = ["*"] # For dev; production should use the CloudFront URL
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["Content-Type"]
  }

  tags = var.tags
}

# resource.aws_apigatewayv2_integration "lambda_integration": Connects the API to our Lambda function.
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_invoke_arn
}

# resource.aws_apigatewayv2_route "upload_route": Creates the route for our UI to call.
# This maps the "POST /uploads" path to our Lambda integration.
resource "aws_apigatewayv2_route" "upload_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /uploads"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# resource.aws_apigatewayv2_stage "default_stage": Deploys the API.
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# resource.aws_lambda_permission "allow_api_gateway_invoke": Grants API Gateway permission to invoke our Lambda.
resource "aws_lambda_permission" "allow_api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_invoke_arn # We use the invoke ARN which doesn't have the alias/version
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}