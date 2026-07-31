resource "aws_sns_topic" "alarms" {
  name = "daviplata-${var.environment}-alarms"
  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  for_each = toset(var.notification_emails)

  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_cloudwatch_metric_alarm" "error_rate" {
  alarm_name          = "daviplata-${var.environment}-error-rate"
  alarm_description   = "Tasa de errores 4xx+5xx de CloudFront por encima del umbral."
  namespace           = "AWS/CloudFront"
  metric_name         = "TotalErrorRate"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.error_rate_threshold
  evaluation_periods  = var.evaluation_periods
  period              = var.period_seconds
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = var.distribution_id
    Region         = "Global"
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
  tags          = var.tags
}

resource "aws_cloudwatch_metric_alarm" "origin_latency" {
  alarm_name          = "daviplata-${var.environment}-origin-latency"
  alarm_description   = "Latencia de origen de CloudFront por encima del umbral."
  namespace           = "AWS/CloudFront"
  metric_name         = "OriginLatency"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.origin_latency_threshold_ms
  evaluation_periods  = var.evaluation_periods
  period              = var.period_seconds
  treat_missing_data  = "notBreaching"

  dimensions = {
    DistributionId = var.distribution_id
    Region         = "Global"
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
          title  = "Requests"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [
            ["AWS/CloudFront", "Requests", "DistributionId", var.distribution_id, "Region", "Global"]
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
          title  = "Tasa de error total (%)"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [
            ["AWS/CloudFront", "TotalErrorRate", "DistributionId", var.distribution_id, "Region", "Global"]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Latencia de origen (ms)"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [
            ["AWS/CloudFront", "OriginLatency", "DistributionId", var.distribution_id, "Region", "Global"]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Cache hit rate (%)"
          view   = "timeSeries"
          region = "us-east-1"
          metrics = [
            ["AWS/CloudFront", "CacheHitRate", "DistributionId", var.distribution_id, "Region", "Global"]
          ]
        }
      }
    ]
  })
}
