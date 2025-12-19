output "ec2_instance_profile_name" {
  description = "EC2 instance profile for container hosts"
  value       = aws_iam_instance_profile.ec2_container_host.name
}

output "tts_service_role_arn" {
  value = aws_iam_role.tts_service.arn
}

output "stt_service_role_arn" {
  value = aws_iam_role.stt_service.arn
}

output "chat_service_role_arn" {
  value = aws_iam_role.chat_service.arn
}

output "document_service_role_arn" {
  value = aws_iam_role.document_service.arn
}

output "quiz_service_role_arn" {
  value = aws_iam_role.quiz_service.arn
}

output "lambda_execution_role_arn" {
  value = aws_iam_role.lambda_execution.arn
}
