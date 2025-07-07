terraform {
  required_providers {
    hostinger = {
      source  = "hostinger/hostinger"
      version = "0.1.6"
    }
  }
}

# CAA Records via Hostinger API
resource "null_resource" "caa_records" {
  for_each = var.aws_caa_records
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
                    "content": "0 issue \"${each.value}\""
                },
                {
                    "content": "0 issuewild \"${each.value}\""
                }
                ],
                "ttl": 14400,
                "type": "CAA"
            }
            ]
        }'
        EOT
  }
}

resource "aws_acm_certificate" "cert" {
  depends_on                = [null_resource.caa_records]
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
  key_algorithm             = "RSA_2048"
  lifecycle {
    create_before_destroy = true
  }
}

resource "hostinger_dns_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
  zone  = var.domain_name
  name  = replace(each.value.name, ".${var.domain_name}.", "")
  type  = each.value.type
  value = each.value.value
  ttl   = 300
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in hostinger_dns_record.cert_validation : "${record.name}.${record.zone}"]
}

output "acm_certificate_arn" {
  # value = aws_acm_certificate.cert.arn
  value = aws_acm_certificate_validation.cert_validation.certificate_arn
}