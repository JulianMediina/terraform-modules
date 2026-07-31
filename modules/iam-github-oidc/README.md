# Módulo: iam-github-oidc

Rol IAM asumible por GitHub Actions vía OIDC (`sts:AssumeRoleWithWebIdentity`), sin llaves de acceso estáticas. Un rol (`gha-<ambiente>`) por ambiente, con permisos least-privilege definidos por quien invoca el módulo.

## Huella del certificado (thumbprint)

El módulo calcula el `thumbprint_list` del proveedor OIDC en tiempo de `apply` con `data "tls_certificate"`, en vez de hardcodear un valor fijo: si GitHub rota la CA de su endpoint OIDC, un thumbprint fijo quedaría obsoleto sin aviso. Esto añade una dependencia del provider `hashicorp/tls` (sin credenciales, solo lee el certificado público del endpoint), declarada en `versions.tf`.

## Por qué un solo proveedor OIDC para los tres roles

AWS solo permite un proveedor OIDC por URL en la cuenta (`token.actions.githubusercontent.com`). Por eso el módulo recibe `create_oidc_provider`: se invoca con `true` una única vez (normalmente para el ambiente `integracion`, en `terraform-foundation/bootstrap`) y con `false` + `existing_oidc_provider_arn` en las siguientes invocaciones.

## Alcance del rol: mismo rol para infraestructura y aplicación

Por diseño (ver `GUIA-PRUEBA-DEVSECOPS_v2.md` §0/§8), cada ambiente tiene un único rol OIDC usado tanto por el pipeline de `terraform-live` (para ese ambiente) como por el de `daviplata-app`. Esto se logra combinando en `allowed_subjects` los patrones `sub` de ambos repositorios, usando GitHub Environments para acotar el claim, por ejemplo:

```hcl
allowed_subjects = [
  "repo:JulianMediina/terraform-live:environment:produccion",
  "repo:JulianMediina/daviplata-app:environment:produccion",
]
```

Esto requiere configurar un GitHub Environment con el mismo nombre (`produccion`, etc.) en ambos repositorios, con las reglas de protección/aprobación correspondientes.

## Permisos (`policy_json`)

El módulo no asume qué puede hacer el rol: quien lo invoca construye el documento de política (least-privilege, acotado por ARN al ambiente correspondiente) y lo pasa en `policy_json`. Esto evita que el módulo termine siendo un "rol admin genérico" reutilizado sin revisar el alcance real necesario en cada ambiente.

## Uso

```hcl
module "gha_role_produccion" {
  source  = "git::https://github.com/JulianMediina/terraform-modules.git//modules/iam-github-oidc?ref=v0.1.0"

  environment                = "produccion"
  create_oidc_provider       = false
  existing_oidc_provider_arn = module.gha_role_integracion.oidc_provider_arn
  allowed_subjects = [
    "repo:JulianMediina/terraform-live:environment:produccion",
    "repo:JulianMediina/daviplata-app:environment:produccion",
  ]
  policy_json = data.aws_iam_policy_document.produccion_least_privilege.json
  tags        = local.common_tags
}
```

## Variables

| Nombre | Tipo | Default | Descripción |
|---|---|---|---|
| `environment` | string | — | `integracion` \| `laboratorio` \| `produccion` |
| `create_oidc_provider` | bool | `false` | Crea el proveedor OIDC (solo una vez por cuenta) |
| `existing_oidc_provider_arn` | string | `null` | ARN del proveedor ya existente, si `create_oidc_provider = false` |
| `allowed_subjects` | list(string) | — | Patrones `StringLike` del claim `sub` autorizados |
| `policy_json` | string | — | Documento de política IAM del rol |
| `max_session_duration` | number | `3600` | Duración máxima de sesión, en segundos |
| `tags` | map(string) | `{}` | Tags adicionales |

## Outputs

| Nombre | Descripción |
|---|---|
| `role_arn` | ARN del rol a usar en `permissions: id-token: write` + `aws-actions/configure-aws-credentials` |
| `oidc_provider_arn` | ARN del proveedor OIDC (para reutilizar en las siguientes invocaciones) |
