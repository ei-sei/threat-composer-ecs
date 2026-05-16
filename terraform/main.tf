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
  cloudflare_zone_id = var.cloudflare_zone_id
}



