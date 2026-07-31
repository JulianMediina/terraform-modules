output "bucket_id" {
  description = "Nombre del bucket."
  value       = aws_s3_bucket.site.id
}

output "bucket_arn" {
  description = "ARN del bucket."
  value       = aws_s3_bucket.site.arn
}

output "bucket_regional_domain_name" {
  description = "Dominio regional del bucket, usado como origen de CloudFront."
  value       = aws_s3_bucket.site.bucket_regional_domain_name
}
