terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "arrise-tfstate-prod-ap-south-1"
    key            = "compute/ec2-cluster/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "arrise-tfstate-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
