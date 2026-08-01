#tfsec:ignore:aws-sns-topic-encryption-use-cmk -- el tópico solo transporta notificaciones de alarmas de CloudWatch (no datos sensibles); una CMK dedicada añade costo sin beneficio real. Ya usa cifrado con la llave administrada de AWS (alias/aws/sns).
resource "aws_sns_topic" "alarms" {
  name              = "daviplata-${var.environment}-alarms"
  kms_master_key_id = "alias/aws/sns"
  tags              = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  for_each = toset(var.notification_emails)

  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "daviplata-${var.environment}-cpu-utilization"
  alarm_description   = "Uso de CPU del servicio ECS por encima del umbral."
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.cpu_utilization_threshold
  evaluation_periods  = var.evaluation_periods
  period              = var.period_seconds
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
  tags          = var.tags
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  alarm_name          = "daviplata-${var.environment}-memory-utilization"
  alarm_description   = "Uso de memoria del servicio ECS por encima del umbral."
  namespace           = "AWS/ECS"
  metric_name         = "MemoryUtilization"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.memory_utilization_threshold
  evaluation_periods  = var.evaluation_periods
  period              = var.period_seconds
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
  tags          = var.tags
}

resource "aws_cloudwatch_dashboard" "site" {
  dashboard_name = "daviplata-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "CPU (%)"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.cluster_name, "ServiceName", var.service_name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Memoria (%)"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.cluster_name, "ServiceName", var.service_name]
          ]
        }
      },
      }
    ]
  })
}
