output "alb_dns_name" {
  value = var.enable_load_balancers ? aws_lb.main[0].dns_name : ""
}

output "alb_arn" {
  value = var.enable_load_balancers ? aws_lb.main[0].arn : ""
}

output "alb_zone_id" {
  value = var.enable_load_balancers ? aws_lb.main[0].zone_id : ""
}

output "alb_security_group_id" {
  value = var.enable_load_balancers ? aws_security_group.alb[0].id : ""
}

output "api_gateway_target_group_arn" {
  value = var.enable_load_balancers ? aws_lb_target_group.api_gateway[0].arn : ""
}

output "kafka_nlb_dns_name" {
  value = var.enable_load_balancers ? aws_lb.kafka[0].dns_name : ""
}

output "kafka_target_group_arn" {
  value = var.enable_load_balancers ? aws_lb_target_group.kafka[0].arn : ""
}
