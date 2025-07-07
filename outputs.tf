# # Certificate outputs
# output "certificate_arn" {
#   description = "ARN of the ACM certificate"
#   value       = aws_acm_certificate.cert.arn
# }

# # S3 bucket outputs
# output "s3_bucket_name" {
#   description = "Name of the S3 bucket"
#   value       = aws_s3_bucket.crc_bucket.bucket
# }

# output "s3_bucket_arn" {
#   description = "ARN of the S3 bucket"
#   value       = aws_s3_bucket.crc_bucket.arn
# }

# output "cloudfront_distribution_id" {
#   description = "ID of the CloudFront distribution"
#   value       = aws_cloudfront_distribution.s3_distribution.id
# }

# output "cloudfront_distribution_arn" {
#   description = "ARN of the CloudFront distribution"
#   value       = aws_cloudfront_distribution.s3_distribution.arn
# }