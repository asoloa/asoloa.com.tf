variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "github_repo" {
  description = "Github Repository"
  type        = string
  sensitive   = true
}

variable "distribution_id" {
  description = "CloudFront Distribution ID"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 Bucket Name"
  type        = string
}

variable "chatbot_api_endpoint" {
  description = "Chatbot API endpoint URL"
  type        = string
  default     = ""
}

variable "github_repo_tf" {
  description = "Github Repository for Terraform (asoloa.com.tf)"
  type        = string
  sensitive   = true
  default     = ""
}