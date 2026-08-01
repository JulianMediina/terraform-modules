variable "repository_name" {
  description = "Nombre completo y único del repositorio."
  type        = string
}

variable "environment" {
  description = "Ambiente al que pertenece el repositorio (integracion, laboratorio, produccion)."
  type        = string

  validation {
    condition     = contains(["integracion", "laboratorio", "produccion"], var.environment)
    error_message = "environment debe ser integracion, laboratorio o produccion."
  }
}

variable "kms_key_arn" {
  description = "ARN de la llave KMS usada para cifrar las imágenes."
  type        = string
}

variable "max_image_count" {
  description = "Número máximo de imágenes etiquetadas (prefijo v) a conservar antes de expirar las más antiguas."
  type        = number
  default     = 20
}

variable "tags" {
  description = "Tags comunes a aplicar al repositorio."
  type        = map(string)
  default     = {}
}
