variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "kafka_subnet_ids" {
  type = list(string)
}

variable "certificate_arn" {
  type    = string
  default = ""
}

variable "enable_load_balancers" {
  description = "Enable load balancers (requires AWS support approval for some accounts)"
  type        = bool
  default     = false
}
