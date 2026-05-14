// ACM Certificate for the domain
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