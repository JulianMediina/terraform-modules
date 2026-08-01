variable "environment" {
  description = "Ambiente monitoreado (integracion, laboratorio, produccion)."
  type        = string

  validation {
    condition     = contains(["integracion", "laboratorio", "produccion"], var.environment)
    error_message = "environment debe ser integracion, laboratorio o produccion."
  }
}

variable "cluster_name" {
  description = "Nombre del cluster ECS a monitorear (dimensión ClusterName en CloudWatch)."
  type        = string
}

variable "service_name" {
  description = "Nombre del servicio ECS a monitorear (dimensión ServiceName en CloudWatch)."
  type        = string
}

variable "notification_emails" {
  description = "Lista de correos suscritos al tópico SNS de alarmas."
  type        = list(string)
  default     = []
}

variable "cpu_utilization_threshold" {
  description = "Umbral (%) de uso de CPU que dispara la alarma."
  type        = number
  default     = 80
}

variable "memory_utilization_threshold" {
  description = "Umbral (%) de uso de memoria que dispara la alarma."
  type        = number
  default     = 80
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
