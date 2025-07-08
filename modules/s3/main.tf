# Creates an AWS S3 bucket for storing website files
resource "aws_s3_bucket" "crc_bucket" {
  bucket        = "${var.domain_name}-bucket"
  force_destroy = true
}

# Blocks public access for the S3 bucket to enhance security
resource "aws_s3_bucket_public_access_block" "crc_bucket" {
  bucket                  = aws_s3_bucket.crc_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Defines an S3 bucket policy for CloudFront to securely access the bucket's contents
resource "aws_s3_bucket_policy" "crc_bucket_policy" {
  bucket = aws_s3_bucket.crc_bucket.id
  policy = <<EOT
    {
        "Version": "2008-10-17",
        "Id": "PolicyForCloudFrontPrivateContent",
        "Statement": [
            {
                "Sid": "AllowCloudFrontServicePrincipal",
                "Effect": "Allow",
                "Principal": {
                    "Service": "cloudfront.amazonaws.com"
                },
                "Action": "s3:GetObject",
                "Resource": "${aws_s3_bucket.crc_bucket.arn}/*",
                "Condition": {
                    "StringEquals": {
                        "AWS:SourceArn": "${var.distribution_arn}"
                    }
                }
            }
        ]
    }
    EOT
}

# Uploads site files to the S3 bucket using `aws s3 sync` command
resource "null_resource" "site_files_upload" {
  provisioner "local-exec" {
    command     = "aws s3 sync ${var.site_files_path}/. s3://${aws_s3_bucket.crc_bucket.id} --delete --exclude '.git/*' --exclude '.git'"
    working_dir = path.root
  }
}