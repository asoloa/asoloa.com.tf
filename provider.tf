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
  default_tags {
    tags = local.common_tags
  }
}

provider "hostinger" {
  api_token = var.hostinger_api_token
}

locals {
  common_tags = {
    project     = "asoloa.com"
    environment = "prod"
    managed_by  = "Terraform"
  }
}