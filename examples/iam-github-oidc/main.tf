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

data "aws_iam_policy_document" "example_least_privilege" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::daviplata-example-*/*"]
  }
}

module "gha_role" {
  source = "../../modules/iam-github-oidc"

  environment          = "integracion"
  create_oidc_provider = true
  allowed_subjects = [
    "repo:JulianMediina/daviplata-app:environment:integracion",
  ]
  policy_json = data.aws_iam_policy_document.example_least_privilege.json
}
