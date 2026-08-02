# Módulo: ssm-publish

Publica un mapa de valores de infraestructura (ARNs, nombres de recursos, URLs — nunca secretos) en SSM Parameter Store, bajo un prefijo de ruta común. Pensado para que un ambiente compuesto en `terraform-live` exponga lo que otro repo (por ejemplo, el pipeline de una aplicación) necesita leer, sin copiar valores a mano entre repos.

## Qué crea

- Un `aws_ssm_parameter` tipo `String` por cada entrada del mapa `parameters`, en `${path_prefix}/<clave>`.

## Uso

```hcl
module "parameters" {
  source = "git::https://github.com/JulianMediina/terraform-modules.git//modules/ssm-publish?ref=v0.3.0"

  path_prefix = "/daviplata/integracion"
  parameters = {
    "ecr/repository-url" = module.registry.repository_url
    "ecs/cluster-name"   = module.service.cluster_name
  }
  tags = local.common_tags
}
```

## Variables

| Nombre | Tipo | Default | Descripción |
|---|---|---|---|
| `path_prefix` | string | — | Prefijo común, sin barra final (ej. `/daviplata/integracion`) |
| `parameters` | map(string) | — | Sufijo de ruta → valor a publicar |
| `tags` | map(string) | `{}` | Tags adicionales |

## Outputs

| Nombre | Descripción |
|---|---|
| `parameter_names` | Mapa de sufijo → nombre completo del parámetro |
| `parameter_arns` | Mapa de sufijo → ARN del parámetro |

## Notas

- Tipo `String`, nunca `SecureString`: este módulo es para valores no sensibles que necesitan descubrirse entre repos, no para secretos. Quien necesite publicar un secreto real no debería usar este módulo.
- Este módulo no define `backend` ni `provider`: los hereda de quien lo invoca.
