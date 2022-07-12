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
}

provider "aws" { # # para criacao do certificado no cloudfront
  region = "eu-central-1"
  profile = "default"
  alias = "eu-central-1"
}

resource "random_pet" "website" {
  length = 5
}