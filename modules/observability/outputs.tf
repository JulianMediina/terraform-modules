output "sns_topic_arn" {
  description = "ARN del tópico SNS de alarmas, para suscribir integraciones adicionales (Slack, Teams)."
  value       = aws_sns_topic.alarms.arn
}

output "dashboard_name" {
  description = "Nombre del dashboard de CloudWatch."
  value       = aws_cloudwatch_dashboard.site.dashboard_name
}
