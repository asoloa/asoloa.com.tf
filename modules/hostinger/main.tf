terraform {
  required_providers {
    hostinger = {
      source  = "hostinger/hostinger"
      version = "0.1.6"
    }
  }
}
# NOTE: I am using curl for some operations due to the unpredictability of the Hostinger provider
# Will perform more tests and update once everything is working as expected

# Adds the AWS CAA (Certification Authority Authorization) DNS records for the domain through the Hostinger API
# If using the hostinger_dns_record resource for this task, it will randomly remove existing records
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

# Adds the DNS records for domain validation (validates domain ownership for the created ACM certificate)
resource "hostinger_dns_record" "cert_validation" {
  for_each = {
    for dvo in var.domain_validation_options : dvo.domain_name => {
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

# Adds an Alias DNS record that points to the CloudFront distribution domain name via Hostinger API
# If using the hostinger_dns_record resource for this task, it will add the record yet will return a provider error
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
                    "content": "${var.distribution_domain_name}"
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