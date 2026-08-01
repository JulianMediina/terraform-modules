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

resource "aws_kms_key" "example" {
  description = "Ejemplo de llave para el módulo ecr"
}

module "registry" {
  source = "../../modules/ecr"

  repository_name = "daviplata-example-site"
  environment     = "integracion"
  kms_key_arn     = aws_kms_key.example.arn
}
