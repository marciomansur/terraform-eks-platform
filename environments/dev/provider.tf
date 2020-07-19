provider "aws" {
  region  = var.region
  profile = var.profile
}

terraform {
  required_version = "~> 0.12.23"

  backend "s3" {
    encrypt        = true
    bucket         = "712621283606-tfstate"
    dynamodb_table = "712621283606-tfstate-lock"
    region         = "eu-central-1"
    key            = "application/dev/platform.tfstate"
  }
}

