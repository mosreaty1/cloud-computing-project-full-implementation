# Test Docker connectivity

Write-Host "Testing Docker..." -ForegroundColor Cyan

# Test 1: Check if Docker command is available
Write-Host "`n1. Checking Docker command..." -ForegroundColor Yellow
try {
    docker --version
    Write-Host "   SUCCESS: Docker command found" -ForegroundColor Green
}
catch {
    Write-Host "   FAILED: Docker command not found" -ForegroundColor Red
    exit 1
}

# Test 2: Check if Docker daemon is running
Write-Host "`n2. Checking Docker daemon..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   SUCCESS: Docker daemon is running" -ForegroundColor Green
    }
    else {
        Write-Host "   FAILED: Docker daemon not responding" -ForegroundColor Red
        Write-Host "   Please start Docker Desktop" -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host "   FAILED: Cannot connect to Docker daemon" -ForegroundColor Red
    Write-Host "   Please start Docker Desktop" -ForegroundColor Yellow
    exit 1
}

# Test 3: Test ECR password retrieval
Write-Host "`n3. Testing ECR password retrieval..." -ForegroundColor Yellow
$password = (aws ecr get-login-password --region us-east-1)
if ($LASTEXITCODE -eq 0 -and $password) {
    Write-Host "   SUCCESS: Got ECR password (length: $($password.Length))" -ForegroundColor Green
}
else {
    Write-Host "   FAILED: Could not get ECR password" -ForegroundColor Red
    exit 1
}

# Test 4: Try alternative ECR login method
Write-Host "`n4. Trying ECR login with alternative method..." -ForegroundColor Yellow
$AWS_ACCOUNT_ID = (aws sts get-caller-identity --query Account --output text)
$ECR_REGISTRY = "$AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com"

# Method 1: Direct command execution
Write-Host "   Method 1: Using cmd /c..." -ForegroundColor Cyan
$loginCmd = "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REGISTRY"
cmd /c $loginCmd 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "   SUCCESS: Logged in to ECR!" -ForegroundColor Green
}
else {
    Write-Host "   Method 1 failed, trying Method 2..." -ForegroundColor Yellow

    # Method 2: Use Invoke-Expression
    Write-Host "   Method 2: Using Invoke-Expression..." -ForegroundColor Cyan
    $loginCmd = "(aws ecr get-login-password --region us-east-1) | docker login --username AWS --password-stdin $ECR_REGISTRY"
    Invoke-Expression $loginCmd

    if ($LASTEXITCODE -eq 0) {
        Write-Host "   SUCCESS: Logged in to ECR!" -ForegroundColor Green
    }
    else {
        Write-Host "   FAILED: Could not login to ECR" -ForegroundColor Red
    }
}

Write-Host "`nDocker and ECR tests complete" -ForegroundColor Cyan
