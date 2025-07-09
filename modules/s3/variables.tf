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

variable "api_gateway_api_endpoint" {
  description = "API Gateway API Endpoint"
  type        = string
}

variable "site_files_git_repo" {
  description = "Git repository URL for the site files. Accepts a URL to a Git repository."
  type        = string
}

variable "view_count_html_id" {
  description = "ID of the HTML element to display the view count"
  type        = string
}