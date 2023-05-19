terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      version = ">= 4.0.0"
    } 
  }
}

provider "aws" {
   region = "eu-central-1"
}
