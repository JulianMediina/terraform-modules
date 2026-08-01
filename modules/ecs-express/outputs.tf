output "service_arn" {
  description = "ARN del servicio, usado por el pipeline para actualizar la imagen desplegada."
  value       = aws_ecs_express_gateway_service.site.arn
}

output "cluster_name" {
  description = "Nombre del cluster ECS, usado por el pipeline para dirigir el despliegue."
  value       = aws_ecs_cluster.site.name
}

output "service_name" {
  description = "Nombre del servicio, usado por el pipeline y por el módulo observability (dimensión ServiceName)."
  value       = aws_ecs_express_gateway_service.site.name
}

# Ruta exacta del atributo por confirmar contra el schema real del provider
# en el primer "terraform plan" en CI (recurso nuevo, sin registro público
# navegable al momento de escribir esto); si difiere, se corrige aquí sin
# tocar los módulos que lo consumen.
output "service_endpoint" {
  description = "URL pública HTTPS del servicio."
  value       = try(aws_ecs_express_gateway_service.site.active_configurations[0].ingress_paths[0].endpoint, null)
}

output "execution_role_arn" {
  description = "ARN del rol de ejecución de tareas ECS."
  value       = aws_iam_role.execution.arn
}

output "infrastructure_role_arn" {
  description = "ARN del rol de infraestructura (ALB, target groups, auto-scaling)."
  value       = aws_iam_role.infrastructure.arn
}
