data "aws_iam_policy_document" "execution_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "ecs-express-${var.environment}-execution"
  assume_role_policy = data.aws_iam_policy_document.execution_trust.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# El repositorio ECR se cifra con una llave KMS administrada por el cliente
# (no la llave por defecto de ECR): sin este permiso explícito, ECS falla al
# lanzar la tarea con AccessDenied al intentar descifrar la imagen, aunque el
# rol de ejecución ya tenga permiso de pull vía la policy administrada.
data "aws_iam_policy_document" "execution_kms" {
  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:DescribeKey"]
    resources = [var.kms_key_arn]
  }
}

resource "aws_iam_role_policy" "execution_kms" {
  name   = "ecs-express-${var.environment}-execution-kms"
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.execution_kms.json
}

data "aws_iam_policy_document" "infrastructure_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "infrastructure" {
  name               = "ecs-express-${var.environment}-infrastructure"
  assume_role_policy = data.aws_iam_policy_document.infrastructure_trust.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "infrastructure" {
  role       = aws_iam_role.infrastructure.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRoleforExpressGatewayServices"
}

resource "aws_ecs_cluster" "site" {
  name = "daviplata-${var.environment}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}

# aws_ecs_express_gateway_service es un recurso nuevo del provider (agregado
# en v6.23.0, noviembre 2025): la imagen inicial solo importa en la creación
# del servicio -el pipeline de despliegue actualiza la imagen real fuera de
# Terraform, mismo patrón que el resto de la plataforma (Terraform define la
# forma del servicio, no qué build está activo). lifecycle ignora ese campo
# para que un apply posterior a un despliegue real no lo revierta.
resource "aws_ecs_express_gateway_service" "site" {
  service_name = "daviplata-${var.environment}"
  cluster      = aws_ecs_cluster.site.name

  execution_role_arn      = aws_iam_role.execution.arn
  infrastructure_role_arn = aws_iam_role.infrastructure.arn

  cpu    = var.cpu
  memory = var.memory

  primary_container {
    image          = "${var.repository_url}:${var.initial_image_tag}"
    container_port = var.container_port

    environment {
      name  = "ENVIRONMENT"
      value = var.environment
    }
  }

  health_check_path = var.health_check_path

  scaling_target {
    min_task_count = var.min_task_count
    max_task_count = var.max_task_count
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Component   = "ecs-express"
  })

  lifecycle {
    ignore_changes = [primary_container[0].image]
  }

  depends_on = [
    aws_iam_role_policy_attachment.execution,
    aws_iam_role_policy_attachment.infrastructure,
  ]
}
