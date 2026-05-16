terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.41.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {
  # Run `source .` to load the CLOUDFLARE_API_TOKEN environment variable before running Terraform
}

