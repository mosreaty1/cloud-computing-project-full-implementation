# Deploy Services Script for Windows
# Deploys services to Kubernetes or Docker Swarm

param(
    [string]$Environment = "dev"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deploying Services to $Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if kubectl is available
$kubectlAvailable = $false
try {
    kubectl version --client | Out-Null
    $kubectlAvailable = $true
} catch {
    Write-Host "kubectl not found, will use Docker Swarm..." -ForegroundColor Yellow
}

if ($kubectlAvailable) {
    Write-Host "Using Kubernetes deployment..." -ForegroundColor Green
    Write-Host ""

    # Apply namespace
    Write-Host "Creating namespace..." -ForegroundColor Yellow
    kubectl apply -f kubernetes\base\namespace.yaml

    # Get ECR credentials
    Write-Host "Creating ECR authentication secret..." -ForegroundColor Yellow
    $AWS_ACCOUNT_ID = (aws sts get-caller-identity --query Account --output text)
    $AWS_REGION = if ($env:AWS_REGION) { $env:AWS_REGION } else { "us-east-1" }
    $ECR_REGISTRY = "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

    $ecrPassword = (aws ecr get-login-password --region $AWS_REGION)

    kubectl create secret docker-registry ecr-secret `
        --docker-server=$ECR_REGISTRY `
        --docker-username=AWS `
        --docker-password=$ecrPassword `
        --namespace=learning-platform `
        --dry-run=client -o yaml | kubectl apply -f -

    # Create application secrets
    Write-Host "Creating application secrets..." -ForegroundColor Yellow
    $jwtSecret = if ($env:JWT_SECRET) { $env:JWT_SECRET } else { "change-me-in-production" }
    $openaiKey = if ($env:OPENAI_API_KEY) { $env:OPENAI_API_KEY } else { "" }

    kubectl create secret generic app-secrets `
        --from-literal=jwt-secret=$jwtSecret `
        --from-literal=openai-api-key=$openaiKey `
        --namespace=learning-platform `
        --dry-run=client -o yaml | kubectl apply -f -

    # Update image references in manifests
    Write-Host "Updating image references..." -ForegroundColor Yellow
    Get-ChildItem kubernetes\base\*.yaml | ForEach-Object {
        (Get-Content $_.FullName) -replace '\$\{ECR_REGISTRY\}', $ECR_REGISTRY | Set-Content $_.FullName
    }

    # Apply all service manifests
    Write-Host "Deploying services..." -ForegroundColor Yellow
    kubectl apply -f kubernetes\base\

    # Wait for deployments
    Write-Host "Waiting for deployments to be ready..." -ForegroundColor Yellow
    kubectl wait --for=condition=available --timeout=300s deployment --all -n learning-platform

    # Get service URLs
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Deployment Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Service endpoints:" -ForegroundColor White
    kubectl get services -n learning-platform

} else {
    Write-Host "kubectl not found, using Docker Swarm..." -ForegroundColor Yellow
    Write-Host ""

    # Initialize swarm if not already
    docker swarm init 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Swarm already initialized" -ForegroundColor Yellow
    }

    # Deploy using docker stack
    Write-Host "Deploying stack..." -ForegroundColor Yellow
    docker stack deploy -c docker-compose.yml learning-platform

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Deployment Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Services:" -ForegroundColor White
    docker service ls
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Check health: .\scripts\health-check.ps1" -ForegroundColor Cyan
if ($kubectlAvailable) {
    Write-Host "  2. View logs: kubectl logs -f deployment/api-gateway -n learning-platform" -ForegroundColor Cyan
    Write-Host "  3. Get load balancer IP: kubectl get svc api-gateway -n learning-platform" -ForegroundColor Cyan
} else {
    Write-Host "  2. View logs: docker service logs learning-platform_api-gateway" -ForegroundColor Cyan
}
Write-Host ""
