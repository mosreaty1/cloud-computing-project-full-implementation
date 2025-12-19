# Build and Push Docker Images to ECR
# For Windows PowerShell

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building and Pushing Docker Images" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Load environment variables from .env
if (Test-Path .env) {
    Get-Content .env | ForEach-Object {
        if ($_ -match '^([^#][^=]+)=(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            Set-Item -Path "env:$name" -Value $value
        }
    }
}

# Check AWS credentials
try {
    aws sts get-caller-identity | Out-Null
} catch {
    Write-Host "Error: AWS credentials not configured" -ForegroundColor Red
    Write-Host "Run: aws configure" -ForegroundColor Yellow
    exit 1
}

# Get AWS account ID and region
$AWS_ACCOUNT_ID = (aws sts get-caller-identity --query Account --output text)
$AWS_REGION = if ($env:AWS_REGION) { $env:AWS_REGION } else { "us-east-1" }
$ECR_REGISTRY = "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

Write-Host "AWS Account: $AWS_ACCOUNT_ID" -ForegroundColor Green
Write-Host "AWS Region: $AWS_REGION" -ForegroundColor Green
Write-Host "ECR Registry: $ECR_REGISTRY" -ForegroundColor Green
Write-Host ""

# Login to ECR
Write-Host "Logging in to Amazon ECR..." -ForegroundColor Yellow
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to login to ECR" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Logged in to ECR" -ForegroundColor Green
Write-Host ""

# Services to build
$services = @(
    "tts-service",
    "stt-service",
    "chat-service",
    "document-reader",
    "quiz-service",
    "api-gateway"
)

# Build and push each service
foreach ($service in $services) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Building $service" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

    # Check if service directory exists
    if (-not (Test-Path "services\$service")) {
        Write-Host "Warning: services\$service directory not found, skipping..." -ForegroundColor Yellow
        continue
    }

    # Repository name
    $repoName = "learning-platform/$service"

    # Create ECR repository if it doesn't exist
    Write-Host "Ensuring ECR repository exists: $repoName" -ForegroundColor Yellow
    aws ecr describe-repositories --repository-names $repoName --region $AWS_REGION 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Creating repository: $repoName" -ForegroundColor Yellow
        aws ecr create-repository --repository-name $repoName --region $AWS_REGION | Out-Null
    }

    # Build image
    Write-Host "Building Docker image for $service..." -ForegroundColor Yellow
    Set-Location "services\$service"
    docker build -t ${service}:latest .

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to build $service" -ForegroundColor Red
        Set-Location ..\..
        continue
    }

    # Tag image
    $imageTag = Get-Date -Format "yyyyMMdd-HHmmss"
    Write-Host "Tagging image with tags: latest, $imageTag" -ForegroundColor Yellow
    docker tag ${service}:latest ${ECR_REGISTRY}/${repoName}:latest
    docker tag ${service}:latest ${ECR_REGISTRY}/${repoName}:${imageTag}

    # Push images
    Write-Host "Pushing images to ECR..." -ForegroundColor Yellow
    docker push ${ECR_REGISTRY}/${repoName}:latest
    docker push ${ECR_REGISTRY}/${repoName}:${imageTag}

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Successfully built and pushed $service" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to push $service" -ForegroundColor Red
    }

    Set-Location ..\..
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All images built and pushed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Images pushed to:" -ForegroundColor White
foreach ($service in $services) {
    Write-Host "  - ${ECR_REGISTRY}/learning-platform/${service}:latest" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Deploy services: .\scripts\deploy-services.ps1 -Environment dev" -ForegroundColor Cyan
Write-Host "  2. Check health: .\scripts\health-check.ps1" -ForegroundColor Cyan
Write-Host ""
