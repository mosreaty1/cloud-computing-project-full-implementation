variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "kafka_subnet_ids" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "iam_instance_profile_name" {
  type = string
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instances (Amazon Linux 2023 recommended)"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "kafka_instance_type" {
  type    = string
  default = "t3.large"
}

variable "zookeeper_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "desired_capacity" {
  type    = number
  default = 3
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 6
}

variable "kafka_broker_count" {
  type    = number
  default = 3
}

variable "zookeeper_node_count" {
  type    = number
  default = 3
}

variable "target_group_arns" {
  type    = list(string)
  default = []
}

variable "aws_region" {
  type = string
}
