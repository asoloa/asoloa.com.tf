variable "access_key" {
  description = "AWS Access Key ID [currently stored as env variable]"
  type        = string
  sensitive   = true
}

variable "secret_key" {
  description = "AWS Access Secret Key [currently stored as env variable]"
  type        = string
  sensitive   = true
}

variable "hostinger_api_token" {
  description = "Hostinger API Token [currently stored as env variable]"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Domain Name"
  type = string
}

variable "aws_caa_records" {
  description = "AWS CAA Records"
  type        = set(string)
  default     = ["amazon.com", "amazontrust.com", "awstrust.com", "amazonaws.com"]
}