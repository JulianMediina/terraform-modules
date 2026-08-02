# Módulo: ecr

Repositorio ECR privado como origen de imágenes para el módulo `ecs-express`. Cifrado con KMS, escaneo de vulnerabilidades en cada push y tags inmutables (una vez publicado un tag `vX.Y.Z` no puede sobrescribirse, solo expirar).

## Qué crea

- Repositorio ECR con `image_tag_mutability = "IMMUTABLE"`.
- Escaneo de vulnerabilidades automático en cada `docker push` (`scan_on_push`).
- Cifrado en reposo con SSE-KMS.
- Política de ciclo de vida: expira imágenes sin tag tras 1 día (builds intermedios nunca desplegados) y conserva solo las últimas `max_image_count` imágenes con tag de versión.

## Uso

```hcl
module "registry" {
  source  = "git::https://github.com/JulianMediina/terraform-modules.git//modules/ecr?ref=v0.2.0"

  repository_name = "daviplata-integracion-site"
  environment     = "integracion"
  kms_key_arn     = data.aws_kms_alias.site.target_key_arn
  tags            = local.common_tags
}
```

## Variables

| Nombre | Tipo | Default | Descripción |
|---|---|---|---|
| `repository_name` | string | — | Nombre completo del repositorio |
| `environment` | string | — | `integracion` \| `laboratorio` \| `produccion` |
| `kms_key_arn` | string | — | ARN de la llave KMS para cifrado |
| `max_image_count` | number | `20` | Imágenes de versión a conservar |
| `tags` | map(string) | `{}` | Tags adicionales |

## Outputs

| Nombre | Descripción |
|---|---|
| `repository_url` | URL del repositorio, usada por el pipeline (`docker push`) y por `ecs-express.repository_url` |
| `repository_arn` | ARN del repositorio |
| `repository_name` | Nombre del repositorio |

## Notas

- Tags inmutables por diseño: fuerza a que cada versión publicada (`vX.Y.Z`) sea de verdad la que corrió en CI, sin posibilidad de que un push posterior la reemplace en silencio.
- Este módulo no define `backend` ni `provider`: los hereda de quien lo invoca.
