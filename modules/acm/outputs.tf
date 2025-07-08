output "domain_validation_options" {
  value = aws_acm_certificate.cert.domain_validation_options
}

output "acm_certificate_arn" {
  value = aws_acm_certificate_validation.cert_validation.certificate_arn
}