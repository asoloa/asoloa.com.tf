variable "domain_name" {
  description = "Domain Name"
  type        = string
}

variable "s3_bucket_domain_name" {
  description = "S3 Bucket Domain Name"
  type        = string
}

variable "s3_bucket_id" {
  description = "S3 Bucket ID"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM Certificate ARN"
  type        = string
}