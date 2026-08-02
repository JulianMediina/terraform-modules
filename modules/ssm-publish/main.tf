# Tipo String, no SecureString, a propósito: este módulo es para publicar
# valores de infraestructura que un pipeline consumidor necesita conocer
# (ARNs, nombres de recursos, URLs) para no depender de que alguien los
# copie a mano entre repos — nunca para secretos reales. Quien use este
# módulo para pasar un valor sensible se equivocó de herramienta.
# CKV2_AWS_34 (pide cifrado) se excluye en ../../.checkov.yaml con esta
# misma justificación: es un check de grafo, el comentario inline
# #checkov:skip no lo suprime de forma confiable.
resource "aws_ssm_parameter" "this" {
  for_each = var.parameters

  name  = "${var.path_prefix}/${each.key}"
  type  = "String"
  value = each.value
  tags  = var.tags
}
