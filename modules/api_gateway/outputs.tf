output "api_gateway_invoke_url" {
  description = "The invoke URL for the API Gateway stage"
  value       = aws_apigatewayv2_stage.stage.invoke_url
}

output "api_gateway_id" {
  description = "The API Gateway ID (for adding additional routes)"
  value       = aws_apigatewayv2_api.http-api.id
}

output "api_gateway_execution_arn" {
  description = "The execution ARN of the API Gateway (for Lambda permissions)"
  value       = aws_apigatewayv2_api.http-api.execution_arn
}