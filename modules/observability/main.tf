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

# El ALB que crea ECS Express Mode es único por cuenta/región y lo comparten
# los 3 ambientes (confirmado inspeccionando la cuenta real: un solo
# aws_lb con host-header routing por servicio, no uno por ambiente) -no hay
# forma de fijar su nombre desde Terraform, lo asigna AWS con un sufijo
# aleatorio en cada creación. Se ubica por tag en vez de por nombre, y la
# alarma se habilita típicamente en un solo ambiente (var.enable_response_
# time_alarm) para no crear 3 alarmas idénticas -sobre el mismo balanceador-
# bajo 3 nombres de ambiente distintos, que sería engañoso operativamente.
data "aws_resourcegroupstaggingapi_resources" "alb" {
  count = var.enable_response_time_alarm ? 1 : 0

  resource_type_filters = ["elasticloadbalancing:loadbalancer"]

  tag_filter {
    key    = "Component"
    values = ["ecs-express"]
  }
}

locals {
  # El ARN completo es .../loadbalancer/app/<nombre>/<id>; la dimensión
  # LoadBalancer de CloudWatch espera solo "app/<nombre>/<id>".
  alb_arn_suffix = var.enable_response_time_alarm ? split(
    "loadbalancer/",
    data.aws_resourcegroupstaggingapi_resources.alb[0].resource_tag_mapping_list[0].resource_arn
  )[1] : null
}

resource "aws_cloudwatch_metric_alarm" "response_time" {
  count = var.enable_response_time_alarm ? 1 : 0

  alarm_name          = "daviplata-${var.environment}-response-time"
  alarm_description   = "Tiempo de respuesta promedio del balanceador compartido por encima del umbral. Ver comentario junto al data source de este archivo: el ALB es compartido por los 3 ambientes, así que esta alarma refleja tráfico de toda la cuenta, no solo de ${var.environment}."
  namespace           = "AWS/ApplicationELB"
  metric_name         = "TargetResponseTime"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.response_time_threshold_seconds
  evaluation_periods  = var.evaluation_periods
  period              = var.period_seconds
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = local.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
  tags          = var.tags
}

locals {
  base_widgets = [
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
    }
  ]

  response_time_widget = [
    {
      type   = "metric"
      x      = 0
      y      = 6
      width  = 12
      height = 6
      properties = {
        title  = "Tiempo de respuesta del balanceador compartido (s)"
        view   = "timeSeries"
        region = "us-east-1"
        metrics = [
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", local.alb_arn_suffix]
        ]
      }
    }
  ]
}

resource "aws_cloudwatch_dashboard" "site" {
  dashboard_name = "daviplata-${var.environment}"

  dashboard_body = jsonencode({
    widgets = var.enable_response_time_alarm ? concat(local.base_widgets, local.response_time_widget) : local.base_widgets
  })
}
