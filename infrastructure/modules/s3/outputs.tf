output "tts_bucket_name" {
  value = aws_s3_bucket.tts.id
}

output "tts_bucket_arn" {
  value = aws_s3_bucket.tts.arn
}

output "stt_bucket_name" {
  value = aws_s3_bucket.stt.id
}

output "stt_bucket_arn" {
  value = aws_s3_bucket.stt.arn
}

output "chat_bucket_name" {
  value = aws_s3_bucket.chat.id
}

output "chat_bucket_arn" {
  value = aws_s3_bucket.chat.arn
}

output "document_bucket_name" {
  value = aws_s3_bucket.document.id
}

output "document_bucket_arn" {
  value = aws_s3_bucket.document.arn
}

output "quiz_bucket_name" {
  value = aws_s3_bucket.quiz.id
}

output "quiz_bucket_arn" {
  value = aws_s3_bucket.quiz.arn
}

output "shared_bucket_name" {
  value = aws_s3_bucket.shared.id
}

output "shared_bucket_arn" {
  value = aws_s3_bucket.shared.arn
}
