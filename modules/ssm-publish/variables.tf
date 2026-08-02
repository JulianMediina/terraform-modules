variable "path_prefix" {
  description = "Prefijo de ruta común para todos los parámetros, sin barra final (ej. /daviplata/integracion)."
  type        = string
}

variable "parameters" {
  description = "Mapa de sufijo de ruta (sin barra inicial) a valor a publicar bajo path_prefix/<sufijo>."
  type        = map(string)
}

variable "tags" {
  description = "Tags comunes a aplicar a los parámetros."
  type        = map(string)
  default     = {}
}
