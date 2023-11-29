terraform {
  cloud {
    organization = "tf-class-september-20"

    workspaces {
      name = "lab-Nov22"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" // change to your desired AWS region
}