# ECR Module - Container registries for all services

# TTS Service Repository
resource "aws_ecr_repository" "tts" {
  name                 = "${var.project_name}/tts-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.project_name}-tts-service"
    Environment = var.environment
    Service     = "tts"
  }
}

# ECR Lifecycle Policy for TTS
resource "aws_ecr_lifecycle_policy" "tts" {
  repository = aws_ecr_repository.tts.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# STT Service Repository
resource "aws_ecr_repository" "stt" {
  name                 = "${var.project_name}/stt-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.project_name}-stt-service"
    Environment = var.environment
    Service     = "stt"
  }
}

resource "aws_ecr_lifecycle_policy" "stt" {
  repository = aws_ecr_repository.stt.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Chat Service Repository
resource "aws_ecr_repository" "chat" {
  name                 = "${var.project_name}/chat-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.project_name}-chat-service"
    Environment = var.environment
    Service     = "chat"
  }
}

resource "aws_ecr_lifecycle_policy" "chat" {
  repository = aws_ecr_repository.chat.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Document Reader Service Repository
resource "aws_ecr_repository" "document" {
  name                 = "${var.project_name}/document-reader-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.project_name}-document-reader-service"
    Environment = var.environment
    Service     = "document"
  }
}

resource "aws_ecr_lifecycle_policy" "document" {
  repository = aws_ecr_repository.document.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Quiz Service Repository
resource "aws_ecr_repository" "quiz" {
  name                 = "${var.project_name}/quiz-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.project_name}-quiz-service"
    Environment = var.environment
    Service     = "quiz"
  }
}

resource "aws_ecr_lifecycle_policy" "quiz" {
  repository = aws_ecr_repository.quiz.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# API Gateway Repository
resource "aws_ecr_repository" "api_gateway" {
  name                 = "${var.project_name}/api-gateway"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.project_name}-api-gateway"
    Environment = var.environment
    Service     = "api-gateway"
  }
}

resource "aws_ecr_lifecycle_policy" "api_gateway" {
  repository = aws_ecr_repository.api_gateway.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
