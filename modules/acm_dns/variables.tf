variable "domain_name" {
  description = "Domain Name"
  type        = string
}

variable "hostinger_api_token" {
  description = "Hostinger API Token"
  type        = string
  sensitive   = true
}

variable "aws_caa_records" {
  description = "AWS CAA Records"
  type        = set(string)
}