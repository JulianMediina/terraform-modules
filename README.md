# terraform-modules

Módulos Terraform reutilizables para la plataforma de DaviPlata. Este repositorio concentra todos los bloques `resource`; ningún otro repo de la plataforma declara recursos sueltos — solo los componen a través de `module`.

## Contenido

| Módulo | Qué crea |
|---|---|
| [`modules/s3-site`](modules/s3-site) | Bucket S3 privado (versionado, cifrado, Block Public Access) para el origen del sitio estático |
| [`modules/cloudfront-oac`](modules/cloudfront-oac) | Distribución CloudFront con Origin Access Control, HTTPS forzado y cabeceras de seguridad |
| [`modules/acm`](modules/acm) | Certificado ACM validado por DNS (opcional, solo si se usa dominio propio) |
| [`modules/observability`](modules/observability) | Alarmas de CloudWatch, dashboard y tópico SNS |
| [`modules/iam-github-oidc`](modules/iam-github-oidc) | Rol IAM por ambiente asumible por GitHub Actions vía OIDC |

## Convenciones

- Ningún módulo declara `backend` ni `provider` propio: los hereda de quien lo invoca.
- Cada módulo expone `variables.tf`, `outputs.tf` y un `README.md` con su contrato de uso.
- Publicación por **tag semántico** (`vX.Y.Z`); `terraform-live` referencia siempre una versión literal, nunca una rama.
- `examples/<módulo>` contiene un caso de uso mínimo, usado como fixture de validación en CI.

## Versionamiento

Este repo es el único de la plataforma que se queda en **trunk-based development** puro: no tiene "ambientes" (no se despliega, se versiona), así que no aplica el modelo de rama por ambiente que sí usan `terraform-live` y `daviplata-app`. Aun así, ningún cambio va directo a `main` — todo commit entra por PR desde una rama `feature/*` (o `fix/*`), igual que en el resto de repos. Cambios en `modules/` se mergean a `main` vía ese PR (fmt, validate, tflint, tfsec, checkov obligatorios). Al etiquetar un commit de `main` con `vX.Y.Z`, el workflow `module-ci.yml` confirma que el tag pertenece a `main` antes de darlo por válido. `terraform-live` fija esa versión en `source = ...?ref=vX.Y.Z`.

## Pipeline

`.github/workflows/module-ci.yml`: `fmt` → `validate` (por módulo) → `tflint` → `tfsec` + `checkov` (bloqueantes) → validación de tag en push de `v*.*.*`.
