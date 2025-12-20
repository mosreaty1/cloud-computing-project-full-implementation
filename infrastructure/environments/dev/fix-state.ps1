# PowerShell script to fix all Terraform state issues
# Run this from the infrastructure/environments/dev directory

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Terraform State and Resource Cleanup Script" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
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
        Write-Host "✓ Imported successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Skipped (may not exist or already managed)" -ForegroundColor Gray
    }
    Write-Host ""
}

Write-Host "STEP 1: Cleaning up problematic resources..." -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan
Write-Host ""

Write-Host "Deleting old RDS subnet group (references old VPC)..." -ForegroundColor Yellow
aws rds delete-db-subnet-group --db-subnet-group-name learning-platform-db-subnet-group-dev 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Deleted old RDS subnet group" -ForegroundColor Green
} else {
    Write-Host "○ RDS subnet group may not exist or already deleted" -ForegroundColor Gray
}
Write-Host ""

Write-Host "Checking Elastic IP usage..." -ForegroundColor Yellow
Write-Host "Current Elastic IPs:" -ForegroundColor Gray
aws ec2 describe-addresses --query 'Addresses[*].[PublicIp,AllocationId,AssociationId]' --output table
Write-Host ""
Write-Host "⚠️  AWS Free Tier allows only 5 Elastic IPs" -ForegroundColor Yellow
Write-Host "   If you see 5 or more above, you need to release unused ones:" -ForegroundColor Yellow
Write-Host "   1. Go to AWS Console > EC2 > Elastic IPs" -ForegroundColor Yellow
Write-Host "   2. Select unassociated IPs and release them" -ForegroundColor Yellow
Write-Host ""
$continue = Read-Host "Have you checked and released unused EIPs if needed? (y/n)"
if ($continue -ne 'y') {
    Write-Host "Please clean up EIPs first, then run this script again" -ForegroundColor Red
    exit 1
}
Write-Host ""

Write-Host "STEP 2: Importing ECR Repositories..." -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan
Import-TerraformResource "module.ecr.aws_ecr_repository.tts" "learning-platform/tts-service"
Import-TerraformResource "module.ecr.aws_ecr_repository.stt" "learning-platform/stt-service"
Import-TerraformResource "module.ecr.aws_ecr_repository.chat" "learning-platform/chat-service"
Import-TerraformResource "module.ecr.aws_ecr_repository.document" "learning-platform/document-reader-service"
Import-TerraformResource "module.ecr.aws_ecr_repository.quiz" "learning-platform/quiz-service"
Import-TerraformResource "module.ecr.aws_ecr_repository.api_gateway" "learning-platform/api-gateway"

Write-Host "STEP 3: Importing S3 Buckets..." -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan
Import-TerraformResource "module.s3.aws_s3_bucket.tts" "learning-platform-tts-service-storage-dev"
Import-TerraformResource "module.s3.aws_s3_bucket.stt" "learning-platform-stt-service-storage-dev"
Import-TerraformResource "module.s3.aws_s3_bucket.chat" "learning-platform-chat-service-storage-dev"
Import-TerraformResource "module.s3.aws_s3_bucket.document" "learning-platform-document-reader-storage-dev"
Import-TerraformResource "module.s3.aws_s3_bucket.quiz" "learning-platform-quiz-service-storage-dev"
Import-TerraformResource "module.s3.aws_s3_bucket.shared" "learning-platform-shared-assets-dev"

Write-Host "STEP 4: Importing IAM Roles and Instance Profiles..." -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan
Import-TerraformResource "module.iam.aws_iam_role.ec2_container_host" "learning-platform-ec2-container-host-dev"
Import-TerraformResource "module.iam.aws_iam_instance_profile.ec2_container_host" "learning-platform-ec2-container-host-dev"
Import-TerraformResource "module.iam.aws_iam_role.tts_service" "learning-platform-tts-service-dev"
Import-TerraformResource "module.iam.aws_iam_role.stt_service" "learning-platform-stt-service-dev"
Import-TerraformResource "module.iam.aws_iam_role.chat_service" "learning-platform-chat-service-dev"
Import-TerraformResource "module.iam.aws_iam_role.document_service" "learning-platform-document-service-dev"
Import-TerraformResource "module.iam.aws_iam_role.quiz_service" "learning-platform-quiz-service-dev"
Import-TerraformResource "module.iam.aws_iam_role.lambda_execution" "learning-platform-lambda-execution-dev"

Write-Host "STEP 5: Importing VPC Flow Logs Resources..." -ForegroundColor Cyan
Write-Host "--------------------------------------" -ForegroundColor Cyan
Import-TerraformResource "module.vpc.aws_cloudwatch_log_group.vpc_flow_logs" "/aws/vpc/learning-platform-dev"
Import-TerraformResource "module.vpc.aws_iam_role.vpc_flow_logs" "learning-platform-vpc-flow-logs-role-dev"

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host "Import and cleanup completed!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run 'terraform plan' to verify" -ForegroundColor Yellow
Write-Host "2. Run 'terraform apply' to create remaining resources" -ForegroundColor Yellow
Write-Host ""
Write-Host "Note: RDS DB subnet group was deleted - Terraform will create a new one" -ForegroundColor Cyan
Write-Host ""
