# CAA Records via Hostinger API
resource "null_resource" "caa_records" {
  for_each = var.aws_caa_records
  provisioner "local-exec" {
    command = <<EOT
        curl https://developers.hostinger.com/api/dns/v1/zones/asoloa.com \
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

resource "hostinger_dns_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
  zone  = "asoloa.com"
  name  = replace(each.value.name, ".asoloa.com.", "")
  type  = each.value.type
  value = each.value.value
  ttl   = 300
}