# Módulo: observability

Alarmas de CloudWatch, dashboard y tópico SNS para un servicio ECS Express Mode.

## Qué crea

- `aws_sns_topic` + suscripciones por email (una por cada entrada de `notification_emails`). Para Slack/Teams, suscribir un endpoint HTTPS (webhook) al mismo tópico fuera de este módulo o extendiendo `notification_emails` a una variable de endpoints tipados.
- Alarma de uso de CPU (`CPUUtilization`) sobre `cpu_utilization_threshold`.
- Alarma de uso de memoria (`MemoryUtilization`) sobre `memory_utilization_threshold`.
- Dashboard con CPU y memoria del servicio.

## Uso

```hcl
module "observability" {
  source  = "git::https://github.com/JulianMediina/terraform-modules.git//modules/observability?ref=v0.2.0"

  environment          = "produccion"
  cluster_name         = module.service.cluster_name
  service_name         = module.service.service_name
  notification_emails  = ["oncall@example.com"]
  tags                 = local.common_tags
}
```

## Variables

| Nombre | Tipo | Default | Descripción |
|---|---|---|---|
| `environment` | string | — | `integracion` \| `laboratorio` \| `produccion` |
| `cluster_name` | string | — | Nombre del cluster ECS a monitorear |
| `service_name` | string | — | Nombre del servicio ECS a monitorear |
| `notification_emails` | list(string) | `[]` | Correos suscritos a las alarmas |
| `cpu_utilization_threshold` | number | `80` | Umbral (%) de uso de CPU |
| `memory_utilization_threshold` | number | `80` | Umbral (%) de uso de memoria |
| `evaluation_periods` | number | `2` | Períodos consecutivos antes de notificar |
| `period_seconds` | number | `300` | Duración de cada período |
| `tags` | map(string) | `{}` | Tags adicionales |

## Outputs

| Nombre | Descripción |
|---|---|
| `sns_topic_arn` | ARN del tópico, para integrarlo con el pipeline o con Slack/Teams |
| `dashboard_name` | Nombre del dashboard creado |
