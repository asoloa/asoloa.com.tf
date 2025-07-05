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

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in hostinger_dns_record.cert_validation : "${record.name}.${record.zone}"]
}