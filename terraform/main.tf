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

// ACM:

resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    name        = var.domain_name
    environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}
