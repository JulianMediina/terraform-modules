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
  description = "Ejemplo de llave para el módulo cloudfront-oac"
}

module "site_bucket" {
  source = "../../modules/s3-site"

  bucket_name = "daviplata-example-cdn-site"
  environment = "integracion"
  kms_key_arn = aws_kms_key.example.arn
}

module "cdn" {
  source = "../../modules/cloudfront-oac"

  environment                 = "integracion"
  bucket_id                   = module.site_bucket.bucket_id
  bucket_arn                  = module.site_bucket.bucket_arn
  bucket_regional_domain_name = module.site_bucket.bucket_regional_domain_name
}
