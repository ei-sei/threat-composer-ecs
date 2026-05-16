output "validated_certificate" {
  description = "The validated certificate"
  value       = module.acm.validated_certificate
}

output "acm_certificate_status" {
  value = module.acm.certificate_status
}
