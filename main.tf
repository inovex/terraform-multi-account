terraform {
  required_version = "~> 0.11"

  backend "s3" {
    region  = "eu-central-1"
    encrypt = true
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = "${var.aws-account}"
}

provider "template" {
  version = "~> 1.0"
}
