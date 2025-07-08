variable "domain_name" {
  description = "Domain Name"
  type        = string
}

variable "validation_record_fqdns_set" {
  description = "Validation Record FQDNs Set"
  type = map(object({
    id    = string
    name  = string
    zone  = string
    value = string
    type  = string
    ttl   = number
  }))
}