# S3 Module - Isolated storage buckets for each service

# TTS Service Bucket
resource "aws_s3_bucket" "tts" {
  bucket = "${var.project_name}-tts-service-storage-${var.environment}"

  tags = {
    Name        = "${var.project_name}-tts-storage"
    Environment = var.environment
    Service     = "tts"
  }
}

resource "aws_s3_bucket_versioning" "tts" {
  bucket = aws_s3_bucket.tts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tts" {
  bucket = aws_s3_bucket.tts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tts" {
  bucket = aws_s3_bucket.tts.id

  rule {
    id     = "delete-old-audio"
    status = "Enabled"

    expiration {
      days = 7
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tts" {
  bucket = aws_s3_bucket.tts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_cors_configuration" "tts" {
  bucket = aws_s3_bucket.tts.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["*"]  # Configure specific origins in production
    max_age_seconds = 3000
  }
}

# STT Service Bucket
resource "aws_s3_bucket" "stt" {
  bucket = "${var.project_name}-stt-service-storage-${var.environment}"

  tags = {
    Name        = "${var.project_name}-stt-storage"
    Environment = var.environment
    Service     = "stt"
  }
}

resource "aws_s3_bucket_versioning" "stt" {
  bucket = aws_s3_bucket.stt.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "stt" {
  bucket = aws_s3_bucket.stt.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "stt" {
  bucket = aws_s3_bucket.stt.id

  rule {
    id     = "delete-old-audio"
    status = "Enabled"

    expiration {
      days = 7
    }
  }
}

resource "aws_s3_bucket_public_access_block" "stt" {
  bucket = aws_s3_bucket.stt.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Chat Service Bucket
resource "aws_s3_bucket" "chat" {
  bucket = "${var.project_name}-chat-service-storage-${var.environment}"

  tags = {
    Name        = "${var.project_name}-chat-storage"
    Environment = var.environment
    Service     = "chat"
  }
}

resource "aws_s3_bucket_versioning" "chat" {
  bucket = aws_s3_bucket.chat.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "chat" {
  bucket = aws_s3_bucket.chat.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "chat" {
  bucket = aws_s3_bucket.chat.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Document Reader Service Bucket
resource "aws_s3_bucket" "document" {
  bucket = "${var.project_name}-document-reader-storage-${var.environment}"

  tags = {
    Name        = "${var.project_name}-document-storage"
    Environment = var.environment
    Service     = "document"
  }
}

resource "aws_s3_bucket_versioning" "document" {
  bucket = aws_s3_bucket.document.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "document" {
  bucket = aws_s3_bucket.document.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "document" {
  bucket = aws_s3_bucket.document.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Quiz Service Bucket
resource "aws_s3_bucket" "quiz" {
  bucket = "${var.project_name}-quiz-service-storage-${var.environment}"

  tags = {
    Name        = "${var.project_name}-quiz-storage"
    Environment = var.environment
    Service     = "quiz"
  }
}

resource "aws_s3_bucket_versioning" "quiz" {
  bucket = aws_s3_bucket.quiz.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "quiz" {
  bucket = aws_s3_bucket.quiz.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "quiz" {
  bucket = aws_s3_bucket.quiz.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Shared Assets Bucket
resource "aws_s3_bucket" "shared" {
  bucket = "${var.project_name}-shared-assets-${var.environment}"

  tags = {
    Name        = "${var.project_name}-shared-storage"
    Environment = var.environment
    Service     = "shared"
  }
}

resource "aws_s3_bucket_versioning" "shared" {
  bucket = aws_s3_bucket.shared.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "shared" {
  bucket = aws_s3_bucket.shared.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "shared" {
  bucket = aws_s3_bucket.shared.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
