output "validated_certificate" {
  description = "The validated certificate"
  value       = module.acm.validated_certificate
}

output "acm_certificate_status" {
  value = module.acm.certificate_status
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.network.vpc_id

}
