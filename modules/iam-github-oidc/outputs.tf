output "role_arn" {
  description = "ARN del rol que GitHub Actions asume por OIDC para este ambiente."
  value       = aws_iam_role.this.arn
}

output "oidc_provider_arn" {
  description = "ARN del proveedor OIDC usado (creado o existente)."
  value       = local.oidc_provider_arn
}
