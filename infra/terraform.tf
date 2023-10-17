terraform {
  required_version = "1.6.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.15"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

provider "cloudflare" {}