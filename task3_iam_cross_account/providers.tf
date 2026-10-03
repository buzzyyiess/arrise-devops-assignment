terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "account_a"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "account_b"
  region = "ap-south-1"
}
