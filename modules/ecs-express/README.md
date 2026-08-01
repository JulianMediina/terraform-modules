# Módulo: ecs-express

Servicio Amazon ECS Express Mode que sirve la imagen publicada en un repositorio `ecr`. Express Mode provisiona en un solo recurso el servicio Fargate, el Application Load Balancer con TLS, el target group y el auto-scaling — no hay que declararlos por separado.

## Por qué ECS Express Mode y no App Runner

AWS cerró App Runner a clientes nuevos; las cuentas sin uso previo del servicio no pueden crear servicios nuevos. ECS Express Mode es el reemplazo que AWS recomienda para ese caso: misma simplicidad operativa (una imagen, dos roles IAM), pero con el balanceador incluido en el mismo recurso en vez de tener que componerlo aparte.

## Qué crea

- Cluster ECS dedicado al ambiente (`daviplata-<ambiente>`).
- Rol de ejecución de tareas (`AmazonECSTaskExecutionRolePolicy`: pull de imagen + logs a CloudWatch).
- Rol de infraestructura (`AmazonECSInfrastructureRoleforExpressGatewayServices`: permite a ECS provisionar ALB, target group y auto-scaling en la cuenta).
- El servicio Express (`aws_ecs_express_gateway_service`), con health check HTTP y una variable de entorno de runtime (`ENVIRONMENT`, usada por el contenedor para servir el `config.json` correcto).

## Quién actualiza la imagen desplegada

`initial_image_tag` solo fija la imagen en la creación del servicio. Después de eso, el pipeline de la aplicación actualiza la imagen directamente por API, igual que hoy actualiza el contenido de un bucket S3 sin pasar por Terraform. El recurso tiene `lifecycle.ignore_changes` sobre la imagen para que un `terraform plan` posterior a un despliegue real no lo reporte como drift.

## Uso

```hcl
module "service" {
  source  = "git::https://github.com/JulianMediina/terraform-modules.git//modules/ecs-express?ref=v0.2.0"

  environment    = "integracion"
  repository_url = module.registry.repository_url
  kms_key_arn    = data.aws_kms_alias.site.target_key_arn # la misma llave que recibió module.registry
  tags           = local.common_tags
}
```

## Variables

| Nombre | Tipo | Default | Descripción |
|---|---|---|---|
| `environment` | string | — | `integracion` \| `laboratorio` \| `produccion` |
| `repository_url` | string | — | URL del repositorio ECR de origen |
| `kms_key_arn` | string | — | ARN de la llave KMS que cifra el repositorio ECR |
| `initial_image_tag` | string | `"bootstrap"` | Tag usado solo en la creación inicial |
| `container_port` | number | `8080` | Puerto del contenedor |
| `cpu` | number | `256` | CPU de la tarea Fargate (unidades ECS) |
| `memory` | number | `512` | Memoria de la tarea Fargate (MB) |
| `min_task_count` | number | `1` | Tareas mínimas activas |
| `max_task_count` | number | `3` | Tareas máximas |
| `health_check_path` | string | `"/health.json"` | Ruta del health check |
| `tags` | map(string) | `{}` | Tags adicionales |

## Outputs

| Nombre | Descripción |
|---|---|
| `service_arn` | ARN del servicio |
| `cluster_name` | Nombre del cluster ECS |
| `service_name` | Nombre del servicio (dimensión CloudWatch `ServiceName`) |
| `service_endpoint` | URL pública HTTPS del servicio |
| `execution_role_arn` | ARN del rol de ejecución de tareas |
| `infrastructure_role_arn` | ARN del rol de infraestructura |

## Notas

- Recurso de provider reciente (`aws_ecs_express_gateway_service`, agregado en `hashicorp/aws` v6.23.0); el `versions.tf` lo fija como mínimo.
- Sin dominio propio ni CDN por delante: `service_endpoint` ya es HTTPS público con certificado gestionado por AWS, suficiente para acceder al sitio directamente.
- Costo continuo (a diferencia de un bucket S3 estático): el ALB y al menos `min_task_count` tarea Fargate quedan activos aunque no haya tráfico.
