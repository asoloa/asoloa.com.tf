variable "domain_name" {
  description = "Domain Name"
  type        = string
}

variable "distribution_arn" {
  description = "CloudFront Distribution ARN"
  type        = string
}

variable "site_files_path" {
  description = "Path to the site files"
  type        = string
}