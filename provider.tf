terraform {
  required_version        = ">= 1.1.0"
  required_providers {
    aws                   = ">= 4.6.0"
    dns                   = ">= 3.2.3"
    random                = ">= 3.1.2"
  }
}

provider "aws" {
  profile                 = var.aws_profile
  region                  = var.aws_region
}

