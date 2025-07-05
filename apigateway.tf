resource "aws_apigatewayv2_api" "http-api" {
  name          = "${aws_lambda_function.lambda_func.function_name}-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http-api.id
  integration_uri        = aws_lambda_function.lambda_func.invoke_arn
  integration_type       = "AWS_PROXY"
  payload_format_version = "2.0"
}

# Route
resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.http-api.id
  route_key = "ANY /${aws_lambda_function.lambda_func.function_name}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Lambda Permission for HTTP API
resource "aws_lambda_permission" "allow_http_api" {
  statement_id  = "AllowExecutionFromHTTPAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_func.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http-api.execution_arn}/*/*/${aws_lambda_function.lambda_func.function_name}"
}

# Deploy the API (Stage)
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http-api.id
  name        = "default"
  auto_deploy = true
}