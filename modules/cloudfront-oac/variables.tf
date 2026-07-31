variable "environment" {
  description = "Ambiente al que pertenece la distribución (integracion, laboratorio, produccion)."
  type        = string

  validation {
    condition     = contains(["integracion", "laboratorio", "produccion"], var.environment)
    error_message = "environment debe ser integracion, laboratorio o produccion."
  }
}

variable "bucket_id" {
  description = "Nombre del bucket S3 que sirve de origen."
  type        = string
}

variable "bucket_arn" {
  description = "ARN del bucket S3 que sirve de origen, usado en la política de acceso del OAC."
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "Dominio regional del bucket S3, usado como origen de la distribución."
  type        = string
}

variable "price_class" {
  description = "Price class de CloudFront."
  type        = string
  default     = "PriceClass_100"
}

variable "aliases" {
  description = "Dominios alternativos (CNAMEs) de la distribución. Vacío si se usa el dominio por defecto de CloudFront."
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ARN del certificado ACM (us-east-1) para los aliases. Null si se usa el certificado por defecto de CloudFront."
  type        = string
  default     = null
}

variable "default_root_object" {
  description = "Objeto raíz servido por defecto."
  type        = string
  default     = "index.html"
}

variable "tags" {
  description = "Tags comunes a aplicar a la distribución."
  type        = map(string)
  default     = {}
}
