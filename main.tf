terraform {
  required_version = "1.2.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.19.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = "us-east-1"
  profile = "default"
  access_key = "test"
  secret_key = "test"
}

resource "random_pet" "website" {
  length = 5
}