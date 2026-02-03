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

resource "github_actions_secret" "CHATBOT_API_ENDPOINT" {
  # count           = var.chatbot_api_endpoint != "" ? 1 : 0
  repository      = var.github_repo
  secret_name     = "CHATBOT_API_ENDPOINT"
  plaintext_value = var.chatbot_api_endpoint
}

# ============================================================================
# GitHub Actions Secrets & Variables for asoloa.com.tf repo
# Used by chatbot-to-s3.yaml workflow
# ============================================================================

resource "github_actions_secret" "TF_S3_SITE_BUCKET" {
  # count           = var.github_repo_tf != "" ? 1 : 0
  repository      = var.github_repo_tf
  secret_name     = "S3_SITE_BUCKET"
  plaintext_value = var.s3_bucket_name
}

resource "github_actions_secret" "TF_CLOUDFRONT_DIST_ID" {
  # count           = var.github_repo_tf != "" ? 1 : 0
  repository      = var.github_repo_tf
  secret_name     = "CLOUDFRONT_DIST_ID"
  plaintext_value = var.distribution_id
}

resource "github_actions_variable" "TF_AWS_REGION" {
  # count         = var.github_repo_tf != "" ? 1 : 0
  repository    = var.github_repo_tf
  variable_name = "AWS_REGION"
  value         = var.aws_region
}

resource "github_actions_secret" "TF_CHATBOT_API_ENDPOINT" {
  # count           = var.github_repo_tf != "" && var.chatbot_api_endpoint != "" ? 1 : 0
  repository      = var.github_repo_tf
  secret_name     = "CHATBOT_API_ENDPOINT"
  plaintext_value = var.chatbot_api_endpoint
}