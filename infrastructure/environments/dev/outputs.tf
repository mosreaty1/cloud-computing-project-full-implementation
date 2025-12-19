output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.elb.alb_dns_name
}

output "kafka_nlb_dns_name" {
  description = "DNS name of the Kafka Network Load Balancer"
  value       = module.elb.kafka_nlb_dns_name
}

output "kafka_broker_ips" {
  description = "Private IPs of Kafka brokers"
  value       = module.ec2.kafka_broker_private_ips
}

output "zookeeper_ips" {
  description = "Private IPs of Zookeeper nodes"
  value       = module.ec2.zookeeper_private_ips
}

output "ecr_repositories" {
  description = "ECR repository URLs"
  value = {
    tts      = module.ecr.tts_repository_url
    stt      = module.ecr.stt_repository_url
    chat     = module.ecr.chat_repository_url
    document = module.ecr.document_repository_url
    quiz     = module.ecr.quiz_repository_url
    gateway  = module.ecr.api_gateway_repository_url
  }
}

output "s3_buckets" {
  description = "S3 bucket names"
  value = {
    tts      = module.s3.tts_bucket_name
    stt      = module.s3.stt_bucket_name
    chat     = module.s3.chat_bucket_name
    document = module.s3.document_bucket_name
    quiz     = module.s3.quiz_bucket_name
    shared   = module.s3.shared_bucket_name
  }
}

output "rds_endpoints" {
  description = "RDS database endpoints"
  value = {
    stt      = module.rds.stt_db_endpoint
    chat     = module.rds.chat_db_endpoint
    document = module.rds.document_db_endpoint
    quiz     = module.rds.quiz_db_endpoint
    user     = module.rds.user_db_endpoint
  }
  sensitive = true
}
