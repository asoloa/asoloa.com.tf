variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "AWS Access Secret Key"
  type        = string
  sensitive   = true
}

variable "hostinger_api_token" {
  description = "Hostinger API Token"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Domain Name"
  type        = string
}

variable "aws_caa_records" {
  description = "AWS CAA Records"
  type        = set(string)
  default     = ["amazon.com", "amazontrust.com", "awstrust.com", "amazonaws.com"]
}

variable "dynamodb_table" {
  description = "DynamoDB Table"
  type        = string
}

variable "api_gateway_stage" {
  description = "API Gateway Stage"
  type        = string
  default     = "default"
}

variable "site_files_path" {
  description = "Path to the site files"
  type        = string
}