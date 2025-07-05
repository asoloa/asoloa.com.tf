variable "hostinger_api_token" {
  description = "Hostinger API Token [currently stored as env variable]"
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
}