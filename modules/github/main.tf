resource "github_actions_secret" "S3_SITE_BUCKET" {
  repository      = var.github_repo
  secret_name     = "S3_SITE_BUCKET"
  plaintext_value = var.s3_bucket_name
}

resource "github_actions_secret" "CLOUDFRONT_DIST_ID" {
  repository      = var.github_repo
  secret_name     = "CLOUDFRONT_DIST_ID"
  plaintext_value = var.distribution_id
}

resource "github_actions_variable" "AWS_REGION" {
  repository    = var.github_repo
  variable_name = "AWS_REGION"
  value         = var.aws_region
}