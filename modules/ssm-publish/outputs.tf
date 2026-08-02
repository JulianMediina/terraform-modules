output "parameter_names" {
  description = "Mapa de sufijo a nombre completo del parámetro publicado."
  value       = { for k, v in aws_ssm_parameter.this : k => v.name }
}

output "parameter_arns" {
  description = "Mapa de sufijo a ARN del parámetro publicado."
  value       = { for k, v in aws_ssm_parameter.this : k => v.arn }
}
