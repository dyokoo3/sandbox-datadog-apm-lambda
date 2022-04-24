terraform {
  required_version = "1.1.9"
  backend "local" {
    path = "terraform.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.3.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

locals {
  service = "lambda-apm"
  env     = "sandbox"
}
