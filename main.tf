module "acm" {
  # Must wait for Hostinger module to add the AWS CAA records to avoid CAA error
  depends_on                  = [module.hostinger.caa_records-task]
  source                      = "./modules/acm"
  domain_name                 = var.domain_name
  validation_record_fqdns_set = module.hostinger.validation_record_fqdns_set
}

module "hostinger" {
  source                    = "./modules/hostinger"
  hostinger_api_token       = var.hostinger_api_token
  domain_name               = var.domain_name
  aws_caa_records           = var.aws_caa_records
  distribution_domain_name  = module.cloudfront.distribution_domain_name
  domain_validation_options = module.acm.domain_validation_options
}

module "api_gateway" {
  source                 = "./modules/api_gateway"
  api_gateway_stage      = var.api_gateway_stage
  lambda_func_name       = module.lambda.lambda_func_name
  lambda_func_invoke_arn = module.lambda.lambda_func_invoke_arn
}

module "cloudfront" {
  source                = "./modules/cloudfront"
  domain_name           = var.domain_name
  s3_bucket_domain_name = module.s3.s3_bucket_domain_name
  s3_bucket_id          = module.s3.s3_bucket_id
  acm_certificate_arn   = module.acm.acm_certificate_arn
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
  source                   = "./modules/s3"
  domain_name              = var.domain_name
  distribution_arn         = module.cloudfront.distribution_arn
  site_files_path          = var.site_files_path
  site_files_git_repo      = var.site_files_git_repo
  view_count_html_id       = var.view_count_html_id
  api_gateway_api_endpoint = "${module.api_gateway.api_gateway_invoke_url}/${module.lambda.lambda_func_name}"
}

module "github" {
  source               = "./modules/github"
  github_repo          = var.github_repo
  github_repo_tf       = var.github_repo_tf
  distribution_id      = module.cloudfront.distribution_id
  s3_bucket_name       = module.s3.s3_bucket_name
  aws_region           = var.aws_region
  chatbot_api_endpoint = module.chatbot.api_endpoint
}

module "chatbot" {
  source                    = "./modules/chatbot"
  domain_name               = var.domain_name
  openai_api_key            = var.openai_api_key
  api_gateway_id            = module.api_gateway.api_gateway_id
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn
  api_gateway_invoke_url    = module.api_gateway.api_gateway_invoke_url
  s3_bucket_id              = module.s3.s3_bucket_name
}