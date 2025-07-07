module "acm_dns" {
  source              = "./modules/acm_dns"
  hostinger_api_token = var.hostinger_api_token
  domain_name         = var.domain_name
  aws_caa_records     = var.aws_caa_records
}

module "api_gateway" {
  source                 = "./modules/api_gateway"
  api_gateway_stage      = var.api_gateway_stage
  lambda_func_name       = module.lambda.lambda_func_name
  lambda_func_invoke_arn = module.lambda.lambda_func_invoke_arn
}

module "cloudfront" {
  # Added dependency to "acm_dns" module to wait for certificate verification to finish before creating distribution
  # depends_on            = [module.acm_dns]
  source                = "./modules/cloudfront"
  domain_name           = var.domain_name
  s3_bucket_domain_name = module.s3.s3_bucket_domain_name
  s3_bucket_id          = module.s3.s3_bucket_id
  acm_certificate_arn   = module.acm_dns.acm_certificate_arn
  hostinger_api_token   = var.hostinger_api_token
}

module "dynamodb" {
  source         = "./modules/dynamodb"
  dynamodb_table = var.dynamodb_table
}

module "lambda" {
  source                 = "./modules/lambda"
  domain_name            = var.domain_name
  script_file            = "lambda_func.py"
  lambda_handler         = "lambda_handler"
  runtime                = "python3.13"
  dynamodb_table_arn     = module.dynamodb.dynamodb_table_arn
  dynamodb_table_name    = var.dynamodb_table
  dynamodb_table_hashkey = module.dynamodb.dynamodb_table_hashkey
}

module "s3" {
  source           = "./modules/s3"
  domain_name      = var.domain_name
  distribution_arn = module.cloudfront.distribution_arn
  site_files_path  = var.site_files_path
}