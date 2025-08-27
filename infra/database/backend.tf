terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket  = "tf-state-three-tier-app-08272025"
    key     = "envs/dev/database.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
