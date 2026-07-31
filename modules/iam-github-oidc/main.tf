# Se calcula en apply en vez de hardcodear la huella: si GitHub rota la CA de
# su endpoint OIDC, un valor fijo quedaría obsoleto sin previo aviso.
data "tls_certificate" "github_actions" {
  count = var.create_oidc_provider ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions[0].certificates[0].sha1_fingerprint]

  tags = var.tags
}

locals {
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : var.existing_oidc_provider_arn
}

data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.allowed_subjects
    }
  }
}

resource "aws_iam_role" "this" {
  name                 = "gha-${var.environment}"
  assume_role_policy   = data.aws_iam_policy_document.trust.json
  max_session_duration = var.max_session_duration

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

resource "aws_iam_role_policy" "this" {
  name   = "gha-${var.environment}-least-privilege"
  role   = aws_iam_role.this.id
  policy = var.policy_json
}
