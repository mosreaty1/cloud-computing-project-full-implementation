# PowerShell script to fix Terraform state by importing existing resources
# Run this from the infrastructure/environments/dev directory

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Terraform State Fix Script" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will import existing AWS resources into Terraform state" -ForegroundColor Yellow
Write-Host "to resolve 'already exists' errors." -ForegroundColor Yellow
Write-Host ""

# Function to import resource with error handling
function Import-TerraformResource {
    param(
        [string]$ResourceAddress,
        [string]$ResourceId
    )

    Write-Host "Importing: $ResourceAddress" -ForegroundColor Yellow

    $output = terraform import $ResourceAddress $ResourceId 2>&1

    if ($LASTEXITCODE -eq 0 -or $output -match "Resource already managed") {
        Write-Host "✓ Imported successfully or already in state" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to import (may not exist or already managed)" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "Step 1: Importing ECR Repositories..." -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan
Import-TerraformResource "module.ecr.aws_ecr_repository.tts" "learning-platform/tts-service"
Import-TerraformResource "module.ecr.aws_ecr_repository.stt" "learning-platform/stt-service"
Import-TerraformResource "module.ecr.aws_ecr_repository.chat" "learning-platform/chat-service"
Import-TerraformResource "module.ecr.aws_ecr_repository.document" "learning-platform/document-reader-service"
Import-TerraformResource "module.ecr.aws_ecr_repository.quiz" "learning-platform/quiz-service"
Import-TerraformResource "module.ecr.aws_ecr_repository.api_gateway" "learning-platform/api-gateway"

Write-Host "Step 2: Importing S3 Buckets..." -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan
Import-TerraformResource "module.s3.aws_s3_bucket.tts" "learning-platform-tts-service-storage-dev"
Import-TerraformResource "module.s3.aws_s3_bucket.stt" "learning-platform-stt-service-storage-dev"
Import-TerraformResource "module.s3.aws_s3_bucket.chat" "learning-platform-chat-service-storage-dev"
Import-TerraformResource "module.s3.aws_s3_bucket.document" "learning-platform-document-reader-storage-dev"
Import-TerraformResource "module.s3.aws_s3_bucket.quiz" "learning-platform-quiz-service-storage-dev"
Import-TerraformResource "module.s3.aws_s3_bucket.shared" "learning-platform-shared-assets-dev"

Write-Host "Step 3: Importing IAM Roles..." -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan
Import-TerraformResource "module.iam.aws_iam_role.ec2_container_host" "learning-platform-ec2-container-host-dev"
Import-TerraformResource "module.iam.aws_iam_role.tts_service" "learning-platform-tts-service-dev"
Import-TerraformResource "module.iam.aws_iam_role.stt_service" "learning-platform-stt-service-dev"
Import-TerraformResource "module.iam.aws_iam_role.chat_service" "learning-platform-chat-service-dev"
Import-TerraformResource "module.iam.aws_iam_role.document_service" "learning-platform-document-service-dev"
Import-TerraformResource "module.iam.aws_iam_role.quiz_service" "learning-platform-quiz-service-dev"
Import-TerraformResource "module.iam.aws_iam_role.lambda_execution" "learning-platform-lambda-execution-dev"

Write-Host "Step 4: Importing RDS Resources..." -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan
Import-TerraformResource "module.rds.aws_db_subnet_group.main" "learning-platform-db-subnet-group-dev"

Write-Host "Step 5: Importing VPC Flow Logs Resources..." -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan
Import-TerraformResource "module.vpc.aws_cloudwatch_log_group.vpc_flow_logs" "/aws/vpc/learning-platform-dev"
Import-TerraformResource "module.vpc.aws_iam_role.vpc_flow_logs" "learning-platform-vpc-flow-logs-role-dev"

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host "Import process completed!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run 'terraform plan' to verify the state" -ForegroundColor Yellow
Write-Host "2. Run 'terraform apply' to create any missing resources" -ForegroundColor Yellow
Write-Host ""
Write-Host "Note: Load balancers are currently DISABLED because your AWS" -ForegroundColor Cyan
Write-Host "      account requires support approval. To enable them later," -ForegroundColor Cyan
Write-Host "      contact AWS Support, then set enable_load_balancers=true" -ForegroundColor Cyan
Write-Host "      in main.tf" -ForegroundColor Cyan
Write-Host ""
