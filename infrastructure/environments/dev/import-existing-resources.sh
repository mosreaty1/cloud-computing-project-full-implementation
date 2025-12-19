#!/bin/bash
# Script to import existing AWS resources into Terraform state

set -e

echo "Importing existing AWS resources into Terraform state..."

# Import ECR repositories
echo "Importing ECR repositories..."
terraform import module.ecr.aws_ecr_repository.tts learning-platform/tts-service || true
terraform import module.ecr.aws_ecr_repository.stt learning-platform/stt-service || true
terraform import module.ecr.aws_ecr_repository.chat learning-platform/chat-service || true
terraform import module.ecr.aws_ecr_repository.document learning-platform/document-reader-service || true
terraform import module.ecr.aws_ecr_repository.quiz learning-platform/quiz-service || true
terraform import module.ecr.aws_ecr_repository.api_gateway learning-platform/api-gateway || true

# Import S3 buckets
echo "Importing S3 buckets..."
terraform import module.s3.aws_s3_bucket.tts learning-platform-tts-service-storage-dev || true
terraform import module.s3.aws_s3_bucket.stt learning-platform-stt-service-storage-dev || true
terraform import module.s3.aws_s3_bucket.chat learning-platform-chat-service-storage-dev || true
terraform import module.s3.aws_s3_bucket.document learning-platform-document-reader-storage-dev || true
terraform import module.s3.aws_s3_bucket.quiz learning-platform-quiz-service-storage-dev || true
terraform import module.s3.aws_s3_bucket.shared learning-platform-shared-assets-dev || true

# Import IAM roles
echo "Importing IAM roles..."
terraform import module.iam.aws_iam_role.ec2_container_host learning-platform-ec2-container-host-dev || true
terraform import module.iam.aws_iam_role.tts_service learning-platform-tts-service-dev || true
terraform import module.iam.aws_iam_role.stt_service learning-platform-stt-service-dev || true
terraform import module.iam.aws_iam_role.chat_service learning-platform-chat-service-dev || true
terraform import module.iam.aws_iam_role.document_service learning-platform-document-service-dev || true
terraform import module.iam.aws_iam_role.quiz_service learning-platform-quiz-service-dev || true
terraform import module.iam.aws_iam_role.lambda_execution learning-platform-lambda-execution-dev || true

# Import RDS subnet group
echo "Importing RDS subnet group..."
terraform import module.rds.aws_db_subnet_group.main learning-platform-db-subnet-group-dev || true

# Import Target Groups
echo "Importing Target Groups..."
terraform import module.elb.aws_lb_target_group.api_gateway "arn:aws:elasticloadbalancing:us-east-1:671482219193:targetgroup/learning-platform-api-gw-tg-dev/*" || true
terraform import module.elb.aws_lb_target_group.kafka "arn:aws:elasticloadbalancing:us-east-1:671482219193:targetgroup/learning-platform-kafka-tg-dev/*" || true

# Import VPC Flow Logs resources
echo "Importing VPC Flow Logs resources..."
terraform import module.vpc.aws_cloudwatch_log_group.vpc_flow_logs /aws/vpc/learning-platform-dev || true
terraform import module.vpc.aws_iam_role.vpc_flow_logs learning-platform-vpc-flow-logs-role-dev || true

echo "Import complete! Note: Load balancers were not imported as the AWS account doesn't support them."
echo "You may need to modify the infrastructure to work without load balancers."
