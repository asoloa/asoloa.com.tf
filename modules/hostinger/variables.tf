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

variable "domain_validation_options" {
  description = "Domain Validation Options"
  type = set(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_value = string
    resource_record_type  = string
  }))
}

variable "distribution_domain_name" {
  description = "Distribution Domain Name"
  type        = string
}