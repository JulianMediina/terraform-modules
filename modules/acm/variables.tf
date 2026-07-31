variable "domain_name" {
  description = "Dominio principal a certificar."
  type        = string
}

variable "subject_alternative_names" {
  description = "Dominios alternativos (SAN) a incluir en el certificado."
  type        = list(string)
  default     = []
}

variable "hosted_zone_id" {
  description = "ID de la hosted zone de Route53 usada para la validación DNS del certificado."
  type        = string
}

variable "tags" {
  description = "Tags comunes a aplicar al certificado."
  type        = map(string)
  default     = {}
}
