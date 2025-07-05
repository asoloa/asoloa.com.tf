resource "aws_cloudfront_origin_access_control" "cloudfront_oac" {
  name                              = "asoloa.com CloudFront Origin Access Control"
  description                       = "asoloa.com CloudFront Origin Access Control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.crc_bucket.bucket_domain_name
    origin_id                = aws_s3_bucket.crc_bucket.id
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_oac.id
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "asoloa.com CloudFront Distribution"
  default_root_object = "index.html"
  aliases             = ["asoloa.com"]
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.crc_bucket.id
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
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
    # cloudfront_default_certificate = true
  }
}