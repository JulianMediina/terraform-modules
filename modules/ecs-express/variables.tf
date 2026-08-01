variable "environment" {
  description = "Ambiente al que pertenece el servicio (integracion, laboratorio, produccion)."
  type        = string

  validation {
    condition     = contains(["integracion", "laboratorio", "produccion"], var.environment)
    error_message = "environment debe ser integracion, laboratorio o produccion."
  }
}

variable "repository_url" {
  description = "URL del repositorio ECR (salida del módulo ecr) del que se despliega la imagen."
  type        = string
}

variable "initial_image_tag" {
  description = "Tag de imagen usado únicamente en la creación inicial del servicio. Los despliegues reales actualizan la imagen fuera de Terraform; ver nota de lifecycle en main.tf."
  type        = string
  default     = "bootstrap"
}

variable "container_port" {
  description = "Puerto en el que escucha el contenedor."
  type        = number
  default     = 8080
}

variable "cpu" {
  description = "CPU de la tarea Fargate, en unidades ECS (256 = 0.25 vCPU)."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memoria de la tarea Fargate, en MB."
  type        = number
  default     = 512
}

variable "min_task_count" {
  description = "Número mínimo de tareas activas."
  type        = number
  default     = 1
}

variable "max_task_count" {
  description = "Número máximo de tareas activas."
  type        = number
  default     = 3
}

variable "health_check_path" {
  description = "Ruta HTTP usada por el balanceador para el health check del servicio."
  type        = string
  default     = "/health.json"
}

variable "tags" {
  description = "Tags comunes a aplicar a los recursos del servicio."
  type        = map(string)
  default     = {}
}
