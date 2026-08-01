resource "aws_ecr_repository" "site" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Component   = "artifact-registry"
  })
}

resource "aws_ecr_lifecycle_policy" "site" {
  repository = aws_ecr_repository.site.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expira imágenes sin tag (builds intermedios, nunca desplegados)"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Conserva solo las últimas N imágenes de versión"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = var.max_image_count
        }
        action = { type = "expire" }
      }
    ]
  })
}
