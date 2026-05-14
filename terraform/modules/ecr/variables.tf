variable "ecr_repository_name" {
  description = "The name of the ECR repository."
  type        = string
}

variable "environment" {
  description = "The environment to deploy resources in (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}