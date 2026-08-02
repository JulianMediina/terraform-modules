terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "parameters" {
  source = "../../modules/ssm-publish"

  path_prefix = "/daviplata-example/integracion"
  parameters = {
    "ecr/repository-url" = "example.dkr.ecr.us-east-1.amazonaws.com/daviplata-example-site"
    "ecs/cluster-name"   = "daviplata-example"
  }
}
