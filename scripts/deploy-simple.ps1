# Deploy TTS and API Gateway services to EC2
# Simple deployment for the 2 working services

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deploying Services to EC2" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$AWS_ACCOUNT_ID = (aws sts get-caller-identity --query Account --output text)
$AWS_REGION = "us-east-1"
$ECR_REGISTRY = "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

# Get RDS endpoints
Write-Host "Getting RDS endpoints..." -ForegroundColor Yellow
$sttDbEndpoint = (aws rds describe-db-instances --db-instance-identifier learning-platform-stt-db-dev --query "DBInstances[0].Endpoint.Address" --output text)

# Get Kafka broker private IP
Write-Host "Getting Kafka broker IP..." -ForegroundColor Yellow
$kafkaIp = (aws ec2 describe-instances --filters "Name=tag:Name,Values=*kafka-broker*" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)

# Get container host instance
Write-Host "Getting container host..." -ForegroundColor Yellow
$instanceId = (aws ec2 describe-instances --filters "Name=tag:Name,Values=*container-host*" "Name=instance-state-name,Values=running" --query "Reservations[0].Instances[0].InstanceId" --output text)

if ($instanceId -eq "None" -or [string]::IsNullOrEmpty($instanceId)) {
    Write-Host "ERROR: No running container host found" -ForegroundColor Red
    exit 1
}

Write-Host "Container Host: $instanceId" -ForegroundColor Green
Write-Host "Kafka Broker: $kafkaIp:9092" -ForegroundColor Green
Write-Host "STT Database: $sttDbEndpoint" -ForegroundColor Green
Write-Host ""

# Create deployment script
$deployScript = @"
#!/bin/bash
set -e

echo "===== Docker Login to ECR ====="
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

echo ""
echo "===== Stop existing containers ====="
docker stop tts-service api-gateway 2>/dev/null || true
docker rm tts-service api-gateway 2>/dev/null || true

echo ""
echo "===== Pull latest images ====="
docker pull $ECR_REGISTRY/learning-platform/tts-service:latest
docker pull $ECR_REGISTRY/learning-platform/api-gateway:latest

echo ""
echo "===== Start TTS Service ====="
docker run -d \
  --name tts-service \
  --restart unless-stopped \
  -p 8001:8001 \
  -e DATABASE_URL="postgresql://dbadmin:44665544Mms@$sttDbEndpoint:5432/postgres" \
  -e KAFKA_BOOTSTRAP_SERVERS="$kafkaIp:9092" \
  $ECR_REGISTRY/learning-platform/tts-service:latest

echo ""
echo "===== Start API Gateway ====="
docker run -d \
  --name api-gateway \
  --restart unless-stopped \
  -p 8000:8000 \
  -e TTS_SERVICE_URL="http://localhost:8001" \
  -e KAFKA_BOOTSTRAP_SERVERS="$kafkaIp:9092" \
  $ECR_REGISTRY/learning-platform/api-gateway:latest

echo ""
echo "===== Service Status ====="
docker ps --filter name=tts-service --filter name=api-gateway

echo ""
echo "===== Deployment Complete ====="
echo "TTS Service: http://localhost:8001"
echo "API Gateway: http://localhost:8000"
"@

# Save script to temp file
$scriptFile = "$env:TEMP\deploy-services.sh"
$deployScript | Out-File -FilePath $scriptFile -Encoding ASCII

Write-Host "Deploying services to EC2 instance $instanceId..." -ForegroundColor Yellow
Write-Host ""

# Upload and execute script via SSM
aws ssm send-command `
    --instance-ids $instanceId `
    --document-name "AWS-RunShellScript" `
    --parameters "commands=@($deployScript -split "`n")" `
    --region $AWS_REGION `
    --output text `
    --query "Command.CommandId"

Write-Host ""
Write-Host "Deployment command sent!" -ForegroundColor Green
Write-Host "Check status in AWS Console > Systems Manager > Run Command" -ForegroundColor Yellow
Write-Host ""
Write-Host "Or view logs:" -ForegroundColor Cyan
Write-Host "aws ssm start-session --target $instanceId" -ForegroundColor White
Write-Host "docker logs tts-service" -ForegroundColor White
Write-Host "docker logs api-gateway" -ForegroundColor White

# Cleanup
Remove-Item $scriptFile -ErrorAction SilentlyContinue
