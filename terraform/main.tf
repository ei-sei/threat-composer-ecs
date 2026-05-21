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
  source             = "./modules/acm"
  domain_name        = var.domain_name
  environment        = var.environment
  cloudflare_zone_id = var.cloudflare_zone_id
}


module "alb" {
  source            = "./modules/alb"
  environment       = var.environment
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  certificate_arn   = module.acm.certificate_arn
}

module "ecs" {
  source                = "./modules/ecs"
  aws_region            = var.aws_region
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  ecr_repository_url    = module.ecr.ecr_repository_url
  alb_security_group_id = module.alb.alb_security_group_id
  private_subnet_id     = module.network.private_subnet_ids
  target_group_arn      = module.alb.target_group_arn
  depends_on            = [module.network, module.alb, module.ecr]
}

resource "cloudflare_dns_record" "app" {
  zone_id = var.cloudflare_zone_id
  name    = "tm"
  type    = "CNAME"
  content = module.alb.alb_dns_name
  ttl     = 300
  proxied = false
}
