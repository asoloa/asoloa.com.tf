variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "github_repo" {
  description = "Github Repository"
  type        = string
  sensitive   = true
}

variable "distribution_arn" {
  description = "CloudFront Distribution ARN"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 Bucket Name"
  type        = string
}