resource "aws_cloudfront_origin_access_control" "cloudfront_oac" {
  name                              = "${var.domain_name} CloudFront OAC"
  description                       = "${var.domain_name} CloudFront OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

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

resource "null_resource" "cloudfront_alias" {
  provisioner "local-exec" {
    command = <<EOT
        curl https://developers.hostinger.com/api/dns/v1/zones/${var.domain_name} \
            --request PUT \
            --header 'Content-Type: application/json' \
            --header 'Authorization: Bearer ${var.hostinger_api_token}' \
            --data '{
            "overwrite": false,
            "zone": [
            {
                "name": "@",
                "records": [
                {
                    "content": "\"${aws_cloudfront_distribution.s3_distribution.domain_name}\""
                }
                ],
                "ttl": 14400,
                "type": "CNAME"
            }
            ]
        }'
        EOT
  }
}

output "distribution_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "distribution_arn" {
  value = aws_cloudfront_distribution.s3_distribution.arn
}