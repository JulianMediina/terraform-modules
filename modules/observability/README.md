# Módulo: observability

Alarmas de CloudWatch, dashboard y tópico SNS para una distribución CloudFront. Las métricas de CloudFront son globales pero se reportan siempre en `us-east-1`; como toda la infraestructura de este proyecto ya vive en `us-east-1`, no hace falta un alias de provider adicional (a diferencia del módulo `acm`).

## Qué crea

- `aws_sns_topic` + suscripciones por email (una por cada entrada de `notification_emails`). Para Slack/Teams, suscribir un endpoint HTTPS (webhook) al mismo tópico fuera de este módulo o extendiendo `notification_emails` a una variable de endpoints tipados.
- Alarma de tasa de error (`TotalErrorRate` 4xx+5xx) sobre `error_rate_threshold`.
- Alarma de latencia de origen (`OriginLatency`) sobre `origin_latency_threshold_ms`.
- Dashboard con requests, tasa de error, latencia de origen y cache hit rate.

## Uso

```hcl
module "observability" {
  source  = "git::https://github.com/JulianMediina/terraform-modules.git//modules/observability?ref=v0.1.0"

  environment          = "produccion"
  distribution_id      = module.cdn.distribution_id
  notification_emails  = ["oncall@example.com"]
  tags                 = local.common_tags
}
```

## Variables

| Nombre | Tipo | Default | Descripción |
|---|---|---|---|
| `environment` | string | — | `integracion` \| `laboratorio` \| `produccion` |
| `distribution_id` | string | — | ID de la distribución CloudFront a monitorear |
| `notification_emails` | list(string) | `[]` | Correos suscritos a las alarmas |
| `error_rate_threshold` | number | `5` | Umbral (%) de errores 4xx+5xx |
| `origin_latency_threshold_ms` | number | `2000` | Umbral de latencia de origen |
| `evaluation_periods` | number | `2` | Períodos consecutivos antes de notificar |
| `period_seconds` | number | `300` | Duración de cada período |
| `tags` | map(string) | `{}` | Tags adicionales |

## Outputs

| Nombre | Descripción |
|---|---|
| `sns_topic_arn` | ARN del tópico, para integrarlo con el pipeline o con Slack/Teams |
| `dashboard_name` | Nombre del dashboard creado |
