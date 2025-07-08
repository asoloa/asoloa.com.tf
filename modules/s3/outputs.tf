output "s3_bucket_domain_name" {
  value = aws_s3_bucket.crc_bucket.bucket_domain_name
}

output "s3_bucket_id" {
  value = aws_s3_bucket.crc_bucket.id
}