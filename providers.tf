terraform {
  required_version = ">= 1.0.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.10.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 0.24.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"  # Current stable version of archive provider
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"  # Current stable version of random provider
    }
  }
}
