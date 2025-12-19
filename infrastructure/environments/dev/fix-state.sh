#!/bin/bash
# Script to fix Terraform state by importing existing resources
# Run this from the infrastructure/environments/dev directory

set -e

echo "=================================================="
echo "Terraform State Fix Script"
echo "=================================================="
echo ""
echo "This script will import existing AWS resources into Terraform state"
echo "to resolve 'already exists' errors."
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to import resource with error handling
import_resource() {
    local resource_address=$1
    local resource_id=$2

    echo -e "${YELLOW}Importing: $resource_address${NC}"
    if terraform import "$resource_address" "$resource_id" 2>&1 | grep -q "Resource already managed"; then
        echo -e "${GREEN}✓ Already in state${NC}"
    elif terraform import "$resource_address" "$resource_id" 2>&1; then
        echo -e "${GREEN}✓ Imported successfully${NC}"
    else
        echo -e "${RED}✗ Failed to import (may not exist or already managed)${NC}"
    fi
    echo ""
}

echo "Step 1: Importing ECR Repositories..."
echo "--------------------------------------"
import_resource "module.ecr.aws_ecr_repository.tts" "learning-platform/tts-service"
import_resource "module.ecr.aws_ecr_repository.stt" "learning-platform/stt-service"
import_resource "module.ecr.aws_ecr_repository.chat" "learning-platform/chat-service"
import_resource "module.ecr.aws_ecr_repository.document" "learning-platform/document-reader-service"
import_resource "module.ecr.aws_ecr_repository.quiz" "learning-platform/quiz-service"
import_resource "module.ecr.aws_ecr_repository.api_gateway" "learning-platform/api-gateway"

echo "Step 2: Importing S3 Buckets..."
echo "--------------------------------------"
import_resource "module.s3.aws_s3_bucket.tts" "learning-platform-tts-service-storage-dev"
import_resource "module.s3.aws_s3_bucket.stt" "learning-platform-stt-service-storage-dev"
import_resource "module.s3.aws_s3_bucket.chat" "learning-platform-chat-service-storage-dev"
import_resource "module.s3.aws_s3_bucket.document" "learning-platform-document-reader-storage-dev"
import_resource "module.s3.aws_s3_bucket.quiz" "learning-platform-quiz-service-storage-dev"
import_resource "module.s3.aws_s3_bucket.shared" "learning-platform-shared-assets-dev"

echo "Step 3: Importing IAM Roles..."
echo "--------------------------------------"
import_resource "module.iam.aws_iam_role.ec2_container_host" "learning-platform-ec2-container-host-dev"
import_resource "module.iam.aws_iam_role.tts_service" "learning-platform-tts-service-dev"
import_resource "module.iam.aws_iam_role.stt_service" "learning-platform-stt-service-dev"
import_resource "module.iam.aws_iam_role.chat_service" "learning-platform-chat-service-dev"
import_resource "module.iam.aws_iam_role.document_service" "learning-platform-document-service-dev"
import_resource "module.iam.aws_iam_role.quiz_service" "learning-platform-quiz-service-dev"
import_resource "module.iam.aws_iam_role.lambda_execution" "learning-platform-lambda-execution-dev"

echo "Step 4: Importing RDS Resources..."
echo "--------------------------------------"
import_resource "module.rds.aws_db_subnet_group.main" "learning-platform-db-subnet-group-dev"

echo "Step 5: Importing VPC Flow Logs Resources..."
echo "--------------------------------------"
import_resource "module.vpc.aws_cloudwatch_log_group.vpc_flow_logs" "/aws/vpc/learning-platform-dev"
import_resource "module.vpc.aws_iam_role.vpc_flow_logs" "learning-platform-vpc-flow-logs-role-dev"

echo ""
echo "=================================================="
echo -e "${GREEN}Import process completed!${NC}"
echo "=================================================="
echo ""
echo "Next steps:"
echo "1. Run 'terraform plan' to verify the state"
echo "2. Run 'terraform apply' to create any missing resources"
echo ""
echo "Note: Load balancers are currently DISABLED because your AWS"
echo "      account requires support approval. To enable them later,"
echo "      contact AWS Support, then set enable_load_balancers=true"
echo "      in main.tf"
echo ""
