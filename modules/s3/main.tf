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
    command     = <<EOT
      cd ..
      git clone ${var.site_files_git_repo} site_files
      mkdir -p site_files/assets/js
      cat <<'EOF' > site_files/assets/js/view-count.js
${local.js_contents}
EOF
      sed -Ei 's/^(\s+)(<\/main>)/\1\2\n\n\1<!-- Inserted by Terraform -->\n\1<script src=".\/assets\/js\/view-count.js"><\/script>/' site_files/index.html
      aws s3 sync site_files/. s3://${aws_s3_bucket.crc_bucket.id} --delete --exclude '.git/*' --exclude '.git'
    EOT
    working_dir = path.root
  }
}

locals {
  js_contents = templatefile("${path.module}/src/view-count.tftpl", { api_endpoint : "${var.api_gateway_api_endpoint}", view_count_html_id : "${var.view_count_html_id}" })
}