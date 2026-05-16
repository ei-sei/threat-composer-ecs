module "network" {
  source             = "./modules/vpc"
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  environment        = var.environment
}

module "ecr" {
  source              = "./modules/ecr"
  ecr_repository_name = var.ecr_repository_name
  environment         = var.environment
}

module "acm" {
  source      = "./modules/acm"
  domain_name = var.domain_name
  environment = var.environment
}

# Create Cloudflare DNS record for ACM validation
resource "cloudflare_dns_record" "dns_validation" {
  zone_id = var.cloudflare_zone_id
  name    = tolist(module.acm.domain_validation_options)[0].resource_record_name
  type    = tolist(module.acm.domain_validation_options)[0].resource_record_type
  content = trimsuffix(tolist(module.acm.domain_validation_options)[0].resource_record_value, ".")
  ttl     = 60
  proxied = false
}

# Validate the ACM certificate using the DNS record
resource "aws_acm_certificate_validation" "validated_certificate" {
  certificate_arn = module.acm.certificate_arn
  validation_record_fqdns = [
    tolist(module.acm.domain_validation_options)[0].resource_record_name
  ]
  depends_on = [cloudflare_dns_record.dns_validation]
}

