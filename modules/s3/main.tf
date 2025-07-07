# S3 Bucket Resource
resource "aws_s3_bucket" "crc_bucket" {
  bucket        = "${var.domain_name}-bucket"
  force_destroy = true
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "crc_bucket" {
  bucket                  = aws_s3_bucket.crc_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

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

resource "null_resource" "site_files_upload" {
  provisioner "local-exec" {
    command = "aws s3 sync ${var.site_files_path}/. s3://${aws_s3_bucket.crc_bucket.id} --delete --exclude '.git/*' --exclude '.git'"
    working_dir = path.root
  }
}

output "s3_bucket_domain_name" {
  value = aws_s3_bucket.crc_bucket.bucket_domain_name
}

output "s3_bucket_id" {
  value = aws_s3_bucket.crc_bucket.id
}