# ALB Module
# This module creates an Application Load Balancer (ALB) with HTTP and HTTPS listeners.
# It also sets up a target group for the ALB and configures security groups to allow traffic on the necessary ports.

resource "aws_security_group" "alb_sg" {
  name        = "tm-alb-sg"
  description = "Security group for the ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "tm-alb-sg"
    environment = var.environment
  }
}

# Create the ALB
resource "aws_lb" "alb" {
  name               = "tm-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids


  tags = {
    Name        = "tm-alb"
    environment = var.environment
  }
}

# Create a target group for the ALB
resource "aws_lb_target_group" "tg" {
  name        = "tm-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name        = "tm-tg"
    environment = var.environment
  }
}

# Create HTTP listener that redirects to HTTPS
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name        = "tm-alb-listener-http"
    environment = var.environment
  }
}

# Create HTTPS listener that forwards to the target group
resource "aws_lb_listener" "listener_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  tags = {
    Name        = "tm-alb-listener-https"
    environment = var.environment
  }
}
