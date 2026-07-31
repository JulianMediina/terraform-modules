# Módulo: acm (opcional)

Certificado ACM con validación DNS automática vía Route53. Solo hace falta si se usa un dominio propio en `cloudfront-oac`; con el dominio por defecto de CloudFront (`*.cloudfront.net`) este módulo no se invoca, lo que evita el costo y la complejidad de una hosted zone (ver `docs/cost.md` en `daviplata-app`).

## Requisito de región

CloudFront solo acepta certificados emitidos en `us-east-1`, sin importar la región del resto de la infraestructura. Este módulo no declara `provider`, así que quien lo invoca (`terraform-live`) debe pasar un alias de provider en `us-east-1`:

```hcl
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "certificate" {
  source  = "git::https://github.com/JulianMediina/terraform-modules.git//modules/acm?ref=v0.1.0"
  providers = {
    aws = aws.us_east_1
  }

  domain_name     = "produccion.daviplata.example.com"
  hosted_zone_id  = data.aws_route53_zone.this.zone_id
  tags            = local.common_tags
}
```

## Variables

| Nombre | Tipo | Default | Descripción |
|---|---|---|---|
| `domain_name` | string | — | Dominio principal |
| `subject_alternative_names` | list(string) | `[]` | Dominios adicionales (SAN) |
| `hosted_zone_id` | string | — | Zona Route53 para los registros de validación |
| `tags` | map(string) | `{}` | Tags adicionales |

## Outputs

| Nombre | Descripción |
|---|---|
| `certificate_arn` | ARN del certificado ya validado |
