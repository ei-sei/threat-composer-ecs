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

# ECS Resources:
# ----------------------------------------------------------

# IAM Role for ECS Task Execution
data "aws_iam_policy_document" "ecs_execution_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_assume_role.json
  tags = {
    Name        = "ecs-task-execution-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudWatch Log Group for ECS Tasks
resource "aws_cloudwatch_log_group" "ecs_tasks" {
  name              = "/ecs/${var.environment}-tasks"
  retention_in_days = 7
}


# ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  name = "tm-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "tm-cluster"
    Environment = var.environment
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "tm-task" {
  family                   = "tm-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "tm-container"
    image     = "${module.ecr.ecr_repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = 80
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs_tasks.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])

  tags = {
    Name        = "tm-task"
    Environment = var.environment
  }
}


# ECS Security Group
resource "aws_security_group" "ecs_tasks" {
  name        = "tm-ecs-sg"
  description = "ECS task SG - traffic from ALB only"
  vpc_id      = module.network.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.alb.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "tm-ecs-sg"
    Environment = var.environment
  }
}


# ECS Service
resource "aws_ecs_service" "tm-service" {
  name            = "tm-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.tm-task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.network.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.alb.target_group_arn
    container_name   = "tm-container"
    container_port   = 80
  }

  depends_on = [module.alb]

  tags = {
    Name        = "tm-service"
    Environment = var.environment
  }
}
