# Main configuration file
# Individual resources are organized in separate files:
# - dns.tf: DNS and CAA records
# - acm.tf: SSL/TLS certificates
# - s3.tf: S3 bucket resources

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0"
    }
    hostinger = {
      source  = "hostinger/hostinger"
      version = "0.1.6"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

provider "hostinger" {
  api_token = var.hostinger_api_token
}

# Local values (if any)
locals {
  common_tags = {
    project     = "Cloud Resume Challenge"
    environment = "asoloa.com"
    managed_by  = "Terraform"
  }
}