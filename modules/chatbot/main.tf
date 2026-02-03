# ============================================================================
# Chatbot Module - Lambda + API Gateway Integration
# 
# This module provisions:
# - Lambda function for OpenAI chatbot proxy
# - API Gateway route (reuses existing API from api_gateway module)
# - Generates chatbot.js with injected API endpoint
# ============================================================================

# ----------------------------------------------------------------------------
# IAM Role for Lambda Execution
# ----------------------------------------------------------------------------
resource "aws_iam_role" "chatbot_lambda_exec" {
  name = "${replace(var.domain_name, ".", "_")}-chatbot-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach AWSLambdaBasicExecutionRole policy for CloudWatch Logs
resource "aws_iam_role_policy_attachment" "chatbot_lambda_basic" {
  role       = aws_iam_role.chatbot_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ----------------------------------------------------------------------------
# Lambda Function Package
# ----------------------------------------------------------------------------
data "archive_file" "chatbot_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/src/index.mjs"
  output_path = "${path.module}/src/chatbot-lambda.zip"
}

# ----------------------------------------------------------------------------
# Lambda Function
# ----------------------------------------------------------------------------
resource "aws_lambda_function" "chatbot_proxy" {
  filename         = data.archive_file.chatbot_lambda_zip.output_path
  function_name    = "${replace(var.domain_name, ".", "_")}-chatbot-proxy"
  role             = aws_iam_role.chatbot_lambda_exec.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.chatbot_lambda_zip.output_base64sha256

  runtime     = var.runtime
  timeout     = var.timeout
  memory_size = var.memory_size

  environment {
    variables = {
      OPENAI_API_KEY = var.openai_api_key
    }
  }
}

# ----------------------------------------------------------------------------
# API Gateway Integration (reuses existing API from api_gateway module)
# ----------------------------------------------------------------------------
resource "aws_apigatewayv2_integration" "chatbot" {
  api_id                 = var.api_gateway_id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.chatbot_proxy.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "chatbot" {
  api_id    = var.api_gateway_id
  route_key = var.chatbot_route_key
  target    = "integrations/${aws_apigatewayv2_integration.chatbot.id}"
}

# ----------------------------------------------------------------------------
# Lambda Permission for API Gateway
# ----------------------------------------------------------------------------
resource "aws_lambda_permission" "chatbot_api_gateway" {
  statement_id  = "AllowAPIGatewayInvokeChatbot"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chatbot_proxy.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}

# ----------------------------------------------------------------------------
# Local Values for Generated Content
# ----------------------------------------------------------------------------
locals {
  # Extract route path from route_key (e.g., "POST /chat" -> "/chat")
  route_path = trimprefix(var.chatbot_route_key, "POST ")

  # Construct the full API endpoint using the invoke URL from api_gateway module
  api_endpoint = "${var.api_gateway_invoke_url}${local.route_path}"
}
