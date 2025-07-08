# Creates an AWS ACM (Amazon Certificate Manager) certificate for the specified domain
resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
  key_algorithm             = "RSA_2048"
  lifecycle {
    create_before_destroy = true
  }
}

# Validates the ACM certificate
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in var.validation_record_fqdns_set : "${record.name}.${record.zone}"]
}