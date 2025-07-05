module "acm" {
    source = "./modules/acm"
    domain_name = "asoloa.com"
}

module "api_gateway" {
    source = "./modules/api_gateway"
}

module "cloudfront" {
    source = "./modules/cloudfront"
    domain_name = "asoloa.com"
}

module "dns" {
    source = "./modules/dns"
    hostinger_api_token = var.hostinger_api_token
    domain_name = "asoloa.com"
    aws_caa_records = var.aws_caa_records
}

module "dynamodb" {
    source = "./modules/dynamodb"
    dynamodb_table = "visitor-count-table"
}

module "lambda" {
    source = "./modules/lambda"
    script_file = "lambda_func.py"
    domain_name = "asoloa.com"
    lambda_handler = "lambda_handler"
}

module "s3" {
    source = "./modules/s3"
    domain_name = "asoloa.com"
}