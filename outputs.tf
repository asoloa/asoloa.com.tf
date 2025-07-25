output "domain_name" {
  value = var.domain_name
}

output "acm_certificate_arn" {
  value = module.acm.acm_certificate_arn
}

output "s3_bucket_domain_name" {
  value = module.s3.s3_bucket_domain_name
}

output "dynamodb_table_arn" {
  value = module.dynamodb.dynamodb_table_arn
}

output "dynamodb_table_hash_key" {
  value = module.dynamodb.dynamodb_table_hashkey
}

output "cloudfront_distribution_arn" {
  value = module.cloudfront.distribution_arn
}

output "cloudfront_distribution_domain_name" {
  value = module.cloudfront.distribution_domain_name
}

output "lambda_invoke_arn" {
  value = module.lambda.lambda_func_invoke_arn
}

output "lambda_func_name" {
  value = module.lambda.lambda_func_name
}

output "api_gateway_api_endpoint" {
  value = "${module.api_gateway.api_gateway_invoke_url}/${module.lambda.lambda_func_name}"
}