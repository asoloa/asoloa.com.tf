output "caa_records-task" {
  value = null_resource.caa_records
}

output "validation_record_fqdns_set" {
  value = hostinger_dns_record.cert_validation
}