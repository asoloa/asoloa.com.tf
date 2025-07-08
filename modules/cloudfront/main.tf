# Configures an Origin Access Control (OAC) for CloudFront to securely access an S3 bucket
resource "aws_cloudfront_origin_access_control" "cloudfront_oac" {
  name                              = "${var.domain_name} CloudFront OAC"
  description                       = "${var.domain_name} CloudFront OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Creates a CloudFront distribution for an S3 bucket, enabling secure content delivery
# with Origin Access Control (OAC), HTTPS redirection, and custom domain support.
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = var.s3_bucket_domain_name
    origin_id                = var.s3_bucket_id
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_oac.id
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.domain_name} CloudFront Distribution"
  default_root_object = "index.html"
  aliases             = ["${var.domain_name}"]
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_bucket_id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }
}