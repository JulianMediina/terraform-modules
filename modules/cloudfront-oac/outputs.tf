output "distribution_id" {
  description = "ID de la distribución CloudFront."
  value       = aws_cloudfront_distribution.site.id
}

output "distribution_arn" {
  description = "ARN de la distribución CloudFront."
  value       = aws_cloudfront_distribution.site.arn
}

output "distribution_domain_name" {
  description = "Dominio por defecto de la distribución (*.cloudfront.net)."
  value       = aws_cloudfront_distribution.site.domain_name
}
