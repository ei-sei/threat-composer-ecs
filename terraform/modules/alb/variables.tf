variable "environment" {
  description = "The environment for the ACM certificate."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB."
  type        = list(string)

}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS listener."
  type        = string

}
