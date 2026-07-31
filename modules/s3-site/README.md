# Módulo: s3-site

Bucket S3 privado para alojar un sitio estático servido detrás de CloudFront (Origin Access Control). El bucket nunca se expone públicamente: Block Public Access está activo en las cuatro dimensiones y la política de acceso la gestiona el módulo `cloudfront-oac`, que es quien conoce el ARN de la distribución autorizada.

## Qué crea

- Bucket S3 con versionado habilitado (requisito para el rollback: restaurar una versión anterior de un objeto).
- Cifrado por defecto con SSE-KMS (`bucket_key_enabled` activo para reducir costo de llamadas a KMS).
- Block Public Access completo.
- `Ownership Controls` en `BucketOwnerEnforced` (deshabilita ACLs, alineado con la política de acceso solo por OAC).
- Ciclo de vida que expira versiones no vigentes tras `noncurrent_version_expiration_days` días, para controlar el crecimiento de costo por versionado.

## Uso

```hcl
module "site_bucket" {
  source  = "git::https://github.com/JulianMediina/terraform-modules.git//modules/s3-site?ref=v0.1.0"

  bucket_name = "daviplata-integracion-site"
  environment = "integracion"
  kms_key_arn = data.aws_kms_key.site.arn
  tags        = local.common_tags
}
```

## Variables

| Nombre | Tipo | Default | Descripción |
|---|---|---|---|
| `bucket_name` | string | — | Nombre completo del bucket |
| `environment` | string | — | `integracion` \| `laboratorio` \| `produccion` |
| `kms_key_arn` | string | — | ARN de la llave KMS para cifrado |
| `force_destroy` | bool | `false` | Permite destruir el bucket con objetos dentro |
| `noncurrent_version_expiration_days` | number | `30` | Días antes de expirar versiones antiguas |
| `tags` | map(string) | `{}` | Tags adicionales |

## Outputs

| Nombre | Descripción |
|---|---|
| `bucket_id` | Nombre del bucket |
| `bucket_arn` | ARN del bucket |
| `bucket_regional_domain_name` | Dominio regional, usado como origen de CloudFront |

## Notas

- Este módulo no define `backend` ni `provider`: los hereda de quien lo invoca (`terraform-live`).
- La política de bucket que autoriza a CloudFront (OAC) vive en el módulo `cloudfront-oac`, no aquí, porque depende del ARN de la distribución que ese módulo crea.
