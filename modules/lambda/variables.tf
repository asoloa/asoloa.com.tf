variable "domain_name" {
  description = "Domain Name"
  type        = string
}

variable "script_file" {
  description = "Name of the script file"
  type        = string
}

variable "lambda_handler" {
  description = "Name of the lambda function handler"
  type        = string
}

variable "runtime" {
  description = "Runtime of the lambda function"
  type        = string
}