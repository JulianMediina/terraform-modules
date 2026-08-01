terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.23"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_kms_key" "example" {
  description = "Ejemplo de llave para el módulo observability"
}

module "registry" {
  source = "../../modules/ecr"

  repository_name = "daviplata-example-observability-site"
  environment     = "integracion"
  kms_key_arn     = aws_kms_key.example.arn
}

module "service" {
  source = "../../modules/ecs-express"

  environment    = "integracion"
  repository_url = module.registry.repository_url
}

module "observability" {
  source = "../../modules/observability"

  environment         = "integracion"
  cluster_name        = module.service.cluster_name
  service_name        = module.service.service_name
  notification_emails = ["oncall@example.com"]
}
