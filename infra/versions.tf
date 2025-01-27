terraform {
  required_version = ">= 1.9.8"

  cloud {
    organization = "personal-burrt"
    workspaces {
      name = "shared-services"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.76"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}
