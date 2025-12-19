output "tts_repository_url" {
  value = aws_ecr_repository.tts.repository_url
}

output "stt_repository_url" {
  value = aws_ecr_repository.stt.repository_url
}

output "chat_repository_url" {
  value = aws_ecr_repository.chat.repository_url
}

output "document_repository_url" {
  value = aws_ecr_repository.document.repository_url
}

output "quiz_repository_url" {
  value = aws_ecr_repository.quiz.repository_url
}

output "api_gateway_repository_url" {
  value = aws_ecr_repository.api_gateway.repository_url
}
