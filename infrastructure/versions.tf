terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.26.0"
    }
  }

  backend "s3" {
    # profile = "terraform"
    bucket  = "terraform-state-741358071637"
    key     = "aws-website-with-iac/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }

}