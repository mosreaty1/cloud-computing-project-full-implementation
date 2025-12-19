variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tts_bucket_name" {
  description = "TTS service S3 bucket name"
  type        = string
}

variable "stt_bucket_name" {
  description = "STT service S3 bucket name"
  type        = string
}

variable "chat_bucket_name" {
  description = "Chat service S3 bucket name"
  type        = string
}

variable "document_bucket_name" {
  description = "Document service S3 bucket name"
  type        = string
}

variable "quiz_bucket_name" {
  description = "Quiz service S3 bucket name"
  type        = string
}
