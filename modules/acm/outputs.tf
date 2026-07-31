output "certificate_arn" {
  description = "ARN del certificado validado, listo para usar en CloudFront (requiere región us-east-1)."
  value       = aws_acm_certificate_validation.this.certificate_arn
}
