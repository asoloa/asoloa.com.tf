# ============================================================================
# Chatbot Module Outputs
# ============================================================================

output "lambda_function_name" {
  description = "Name of the chatbot Lambda function"
  value       = aws_lambda_function.chatbot_proxy.function_name
}

output "lambda_function_arn" {
  description = "ARN of the chatbot Lambda function"
  value       = aws_lambda_function.chatbot_proxy.arn
}

output "lambda_invoke_arn" {
  description = "Invoke ARN of the chatbot Lambda function"
  value       = aws_lambda_function.chatbot_proxy.invoke_arn
}

output "api_endpoint" {
  description = "Full API endpoint URL for the chatbot"
  value       = local.api_endpoint
}
