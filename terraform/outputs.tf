output "validated_certificate" {
  description = "The validated certificate"
  value       = aws_acm_certificate_validation.validated_certificate
}

output "acm_certificate_status" {
  value = module.acm.certificate_status
}
