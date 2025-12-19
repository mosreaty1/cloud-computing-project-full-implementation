output "container_hosts_security_group_id" {
  value = aws_security_group.container_hosts.id
}

output "kafka_security_group_id" {
  value = aws_security_group.kafka.id
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.container_hosts.name
}

output "kafka_broker_private_ips" {
  value = aws_instance.kafka[*].private_ip
}

output "zookeeper_private_ips" {
  value = aws_instance.zookeeper[*].private_ip
}

output "kafka_broker_ids" {
  value = aws_instance.kafka[*].id
}

output "zookeeper_ids" {
  value = aws_instance.zookeeper[*].id
}
