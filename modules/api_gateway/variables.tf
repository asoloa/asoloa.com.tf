variable "api_gateway_stage" {
  description = "API Gateway Stage"
  type        = string
}

variable "lambda_func_name" {
  description = "Lambda Function Name"
  type        = string
}

variable "lambda_func_invoke_arn" {
  description = "Lambda Function Invoke ARN"
  type        = string
}

variable "domain_name" {
  description = "Domain Name"
  type        = string
}

variable "api_gateway_view-count-resource" {
  description = "API Gateway resource path for view count"
  type        = string
}