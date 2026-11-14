terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.73"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.8"
    }
  }
}

# Every control-plane call goes to the local emulator, never to AWS.
provider "aws" {
  region = var.aws_region

  skip_credentials_validation = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  endpoints {
    iam    = var.emulator_endpoint
    lambda = var.emulator_endpoint
    sns    = var.emulator_endpoint
    sts    = var.emulator_endpoint
  }
}
