# Módulo: cloudfront-oac

Distribución CloudFront delante de un bucket S3 privado, usando Origin Access Control (OAC) en vez de OAI (deprecado). Fuerza HTTPS, aplica una Response Headers Policy con cabeceras de seguridad y adjunta al bucket la política que permite el acceso exclusivo del servicio CloudFront a esta distribución.

## Qué crea

- `aws_cloudfront_origin_access_control` — reemplazo moderno de OAI, firma las peticiones al origen S3 con SigV4.
- `aws_cloudfront_response_headers_policy` — CSP, HSTS (con preload), `X-Content-Type-Options`, `X-Frame-Options: DENY`, `Referrer-Policy`.
- `aws_cloudfront_distribution` — `viewer_protocol_policy = redirect-to-https`, TLS mínimo 1.2, price class configurable.
- `aws_s3_bucket_policy` sobre el bucket recibido por variable: permite lectura solo a `AWS:SourceArn` de **esta** distribución (evita el problema conocido de políticas OAC demasiado permisivas entre distribuciones), exige TLS, y **deniega explícitamente cualquier escritura** (`PutObject`/`DeleteObject`/tags) salvo que la llame el rol `gha-<environment>` — así ni una carga manual con credenciales de administrador, ni el usuario root de la cuenta, pueden modificar el contenido del sitio por fuera del pipeline.

## Por qué la política de bucket vive aquí y no en `s3-site`

El bucket se crea antes que la distribución, pero la política que lo protege necesita el ARN de la distribución (para restringir `SourceArn`). Como este módulo recibe `bucket_id`/`bucket_arn` por variable, puede crear el bucket policy sin que `s3-site` necesite saber nada de CloudFront. Así se evita una dependencia circular entre módulos manteniendo la separación módulo↔resource.

## Uso

```hcl
module "cdn" {
  source  = "git::https://github.com/JulianMediina/terraform-modules.git//modules/cloudfront-oac?ref=v0.1.0"

  environment                 = "produccion"
  bucket_id                   = module.site_bucket.bucket_id
  bucket_arn                  = module.site_bucket.bucket_arn
  bucket_regional_domain_name = module.site_bucket.bucket_regional_domain_name
  price_class                 = "PriceClass_100"
  tags                        = local.common_tags
}
```

## Variables

| Nombre | Tipo | Default | Descripción |
|---|---|---|---|
| `environment` | string | — | `integracion` \| `laboratorio` \| `produccion` |
| `bucket_id` / `bucket_arn` / `bucket_regional_domain_name` | string | — | Salidas del módulo `s3-site` |
| `price_class` | string | `PriceClass_100` | Cobertura geográfica de edge locations |
| `aliases` | list(string) | `[]` | Dominios propios (requiere `acm_certificate_arn`) |
| `acm_certificate_arn` | string | `null` | Certificado ACM en us-east-1; si es `null` se usa el certificado por defecto de CloudFront |
| `default_root_object` | string | `index.html` | Objeto raíz |
| `tags` | map(string) | `{}` | Tags adicionales |

## Outputs

| Nombre | Descripción |
|---|---|
| `distribution_id` | ID de la distribución (usado por el pipeline para invalidaciones) |
| `distribution_arn` | ARN de la distribución |
| `distribution_domain_name` | Dominio `*.cloudfront.net` |
