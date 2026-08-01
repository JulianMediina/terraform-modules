output "repository_url" {
  description = "URL del repositorio, usada para docker push/pull y como origen del servicio ECS Express."
  value       = aws_ecr_repository.site.repository_url
}

output "repository_arn" {
  description = "ARN del repositorio."
  value       = aws_ecr_repository.site.arn
}

output "repository_name" {
  description = "Nombre del repositorio."
  value       = aws_ecr_repository.site.name
}
