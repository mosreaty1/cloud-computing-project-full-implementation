output "stt_db_endpoint" {
  value = aws_db_instance.stt.endpoint
}

output "stt_db_name" {
  value = aws_db_instance.stt.db_name
}

output "chat_db_endpoint" {
  value = aws_db_instance.chat.endpoint
}

output "chat_db_name" {
  value = aws_db_instance.chat.db_name
}

output "document_db_endpoint" {
  value = aws_db_instance.document.endpoint
}

output "document_db_name" {
  value = aws_db_instance.document.db_name
}

output "quiz_db_endpoint" {
  value = aws_db_instance.quiz.endpoint
}

output "quiz_db_name" {
  value = aws_db_instance.quiz.db_name
}

output "user_db_endpoint" {
  value = aws_db_instance.user.endpoint
}

output "user_db_name" {
  value = aws_db_instance.user.db_name
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}
