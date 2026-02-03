# ============================================================================
# Chatbot Module Variables
# ============================================================================

variable "domain_name" {
  description = "Domain name for the website"
  type        = string
}

variable "openai_api_key" {
  description = "OpenAI API key for the chatbot Lambda function"
  type        = string
  sensitive   = true
}

variable "api_gateway_id" {
  description = "API Gateway ID to add the chatbot route to (reused from api_gateway module)"
  type        = string
}

variable "api_gateway_execution_arn" {
  description = "API Gateway execution ARN for Lambda permissions (reused from api_gateway module)"
  type        = string
}

variable "api_gateway_invoke_url" {
  description = "API Gateway invoke URL (reused from api_gateway module)"
  type        = string
}

variable "s3_bucket_id" {
  description = "S3 bucket ID to upload chatbot files to"
  type        = string
}

variable "chatbot_route_key" {
  description = "Route key for the chatbot API endpoint"
  type        = string
  default     = "POST /chat"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "nodejs18.x"
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 20
}

variable "memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 128
}
