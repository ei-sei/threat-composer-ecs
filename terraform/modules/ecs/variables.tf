variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
}

variable "environment" {
  description = "The environment to deploy resources in (e.g., dev, staging, prod)."
  type        = string

}

variable "vpc_id" {
  description = "The ID of the VPC to deploy ECS resources in."
  type        = string
}

variable "alb_security_group_id" {
  description = "The ID of the security group for the ALB."
  type        = string
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository."
  type        = string
}

variable "private_subnet_id" {
  description = "List of private subnet IDs for the ECS tasks."
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the ALB target group to register ECS tasks with."
  type        = string

}
