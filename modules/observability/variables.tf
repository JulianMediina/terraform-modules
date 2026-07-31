variable "environment" {
  description = "Ambiente monitoreado (integracion, laboratorio, produccion)."
  type        = string

  validation {
    condition     = contains(["integracion", "laboratorio", "produccion"], var.environment)
    error_message = "environment debe ser integracion, laboratorio o produccion."
  }
}

variable "distribution_id" {
  description = "ID de la distribución CloudFront a monitorear."
  type        = string
}

variable "notification_emails" {
  description = "Lista de correos suscritos al tópico SNS de alarmas."
  type        = list(string)
  default     = []
}

variable "error_rate_threshold" {
  description = "Umbral (%) de tasa de error 4xx+5xx que dispara la alarma."
  type        = number
  default     = 5
}

variable "origin_latency_threshold_ms" {
  description = "Umbral de latencia de origen (ms) que dispara la alarma."
  type        = number
  default     = 2000
}

variable "evaluation_periods" {
  description = "Número de períodos consecutivos en alarma antes de notificar."
  type        = number
  default     = 2
}

variable "period_seconds" {
  description = "Duración de cada período de evaluación, en segundos."
  type        = number
  default     = 300
}

variable "tags" {
  description = "Tags comunes a aplicar a los recursos de observabilidad."
  type        = map(string)
  default     = {}
}
