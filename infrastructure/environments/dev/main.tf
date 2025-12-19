terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment for remote state
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "learning-platform/dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
}

# S3 Module
module "s3" {
  source = "../../modules/s3"

  project_name = var.project_name
  environment  = var.environment
}

# IAM Module
module "iam" {
  source = "../../modules/iam"

  project_name        = var.project_name
  environment         = var.environment
  tts_bucket_name     = module.s3.tts_bucket_name
  stt_bucket_name     = module.s3.stt_bucket_name
  chat_bucket_name    = module.s3.chat_bucket_name
  document_bucket_name = module.s3.document_bucket_name
  quiz_bucket_name    = module.s3.quiz_bucket_name
}

# ELB Module
module "elb" {
  source = "../../modules/elb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  kafka_subnet_ids      = module.vpc.kafka_subnet_ids
  enable_load_balancers = false  # Set to true after getting AWS support approval
}

# EC2 Module
module "ec2" {
  source = "../../modules/ec2"

  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  kafka_subnet_ids          = module.vpc.kafka_subnet_ids
  alb_security_group_id     = module.elb.alb_security_group_id != "" ? module.elb.alb_security_group_id : module.vpc.vpc_default_security_group_id
  iam_instance_profile_name = module.iam.ec2_instance_profile_name
  ami_id                    = data.aws_ami.amazon_linux_2023.id
  target_group_arns         = module.elb.api_gateway_target_group_arn != "" ? [module.elb.api_gateway_target_group_arn] : []
  aws_region                = var.aws_region

  desired_capacity      = 3
  min_size              = 2
  max_size              = 6
  kafka_broker_count    = 3
  zookeeper_node_count  = 3
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  project_name             = var.project_name
  environment              = var.environment
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.data_subnet_ids
  app_security_group_ids   = [module.ec2.container_hosts_security_group_id]
  db_username              = var.db_username
  db_password              = var.db_password
  db_instance_class        = "db.t3.medium"
  multi_az                 = false  # Set to true for production
}

# ECR Module
module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
  environment  = var.environment
}
