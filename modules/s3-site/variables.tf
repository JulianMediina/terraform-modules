variable "bucket_name" {
  description = "Nombre completo y único del bucket que alojará el sitio estático."
  type        = string
}

variable "environment" {
  description = "Ambiente al que pertenece el bucket (integracion, laboratorio, produccion)."
  type        = string

  validation {
    condition     = contains(["integracion", "laboratorio", "produccion"], var.environment)
    error_message = "environment debe ser integracion, laboratorio o produccion."
  }
}

variable "kms_key_arn" {
  description = "ARN de la llave KMS usada para cifrar los objetos del bucket."
  type        = string
}

variable "force_destroy" {
  description = "Si es true, permite eliminar el bucket aunque contenga objetos. Solo debe usarse en ambientes no productivos."
  type        = bool
  default     = false
}

variable "noncurrent_version_expiration_days" {
  description = "Días antes de expirar versiones no vigentes de los objetos (control de costos)."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags comunes a aplicar al bucket."
  type        = map(string)
  default     = {}
}
