output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "alb_arn" {
  value = aws_lb.main.arn
}

output "alb_zone_id" {
  value = aws_lb.main.zone_id
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "api_gateway_target_group_arn" {
  value = aws_lb_target_group.api_gateway.arn
}

output "kafka_nlb_dns_name" {
  value = aws_lb.kafka.dns_name
}

output "kafka_target_group_arn" {
  value = aws_lb_target_group.kafka.arn
}
