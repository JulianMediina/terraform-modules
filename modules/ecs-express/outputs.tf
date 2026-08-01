output "service_arn" {
  description = "ARN del servicio, usado por el pipeline para actualizar la imagen desplegada."
  value       = aws_ecs_express_gateway_service.site.service_arn
}

output "cluster_name" {
  description = "Nombre del cluster ECS, usado por el pipeline para dirigir el despliegue."
  value       = aws_ecs_cluster.site.name
}

output "service_name" {
  description = "Nombre del servicio, usado por el pipeline y por el módulo observability (dimensión ServiceName)."
  value       = "daviplata-${var.environment}"
}

output "service_endpoint" {
  description = "URL pública HTTPS del servicio."
  value       = aws_ecs_express_gateway_service.site.ingress_paths[0].endpoint
}

output "execution_role_arn" {
  description = "ARN del rol de ejecución de tareas ECS."
  value       = aws_iam_role.execution.arn
}

output "infrastructure_role_arn" {
  description = "ARN del rol de infraestructura (ALB, target groups, auto-scaling)."
  value       = aws_iam_role.infrastructure.arn
}
