variable "environment" {
  description = "Ambiente o identificador del rol (integracion, laboratorio, produccion, o foundation para el rol que se usa a sí mismo en terraform-foundation)."
  type        = string

  validation {
    condition     = contains(["integracion", "laboratorio", "produccion", "foundation"], var.environment)
    error_message = "environment debe ser integracion, laboratorio, produccion o foundation."
  }
}

variable "create_oidc_provider" {
  description = "Si es true, crea el proveedor OIDC de GitHub Actions (solo debe ser true una vez por cuenta AWS)."
  type        = bool
  default     = false
}

variable "existing_oidc_provider_arn" {
  description = "ARN del proveedor OIDC ya existente, requerido cuando create_oidc_provider es false."
  type        = string
  default     = null
}

variable "allowed_subjects" {
  description = "Patrones StringLike para el claim 'sub' del token OIDC que pueden asumir este rol (ej. repo:org/repo:environment:produccion)."
  type        = list(string)
}

variable "policy_json" {
  description = "Documento de política IAM (JSON) con los permisos least-privilege del rol para este ambiente."
  type        = string
}

variable "max_session_duration" {
  description = "Duración máxima de sesión del rol, en segundos."
  type        = number
  default     = 3600
}

variable "tags" {
  description = "Tags comunes a aplicar al rol."
  type        = map(string)
  default     = {}
}
