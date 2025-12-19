# Windows Setup Script for Cloud-Based Learning Platform
# Run this script in PowerShell

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Cloud Learning Platform - Windows Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "WARNING: Not running as Administrator. Some features may not work." -ForegroundColor Yellow
    Write-Host ""
}

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Green

# Check Docker
try {
    $dockerVersion = docker --version
    Write-Host "✓ Docker installed: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is not installed or not in PATH" -ForegroundColor Red
    Write-Host "  Download from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    exit 1
}

# Check Docker Compose
try {
    $composeVersion = docker-compose --version
    Write-Host "✓ Docker Compose installed: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker Compose is not installed" -ForegroundColor Red
    exit 1
}

# Check if Docker is running
try {
    docker ps | Out-Null
    Write-Host "✓ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Check if .env exists
if (-not (Test-Path .env)) {
    Write-Host "Creating .env file from template..." -ForegroundColor Yellow
    Copy-Item .env.example .env
    Write-Host "✓ Created .env file" -ForegroundColor Green
    Write-Host ""
    Write-Host "⚠️  IMPORTANT: Edit .env and add your API keys!" -ForegroundColor Yellow
    Write-Host "   Required:" -ForegroundColor Yellow
    Write-Host "   - OPENAI_API_KEY (from https://platform.openai.com/api-keys)" -ForegroundColor Yellow
    Write-Host "   - JWT_SECRET (run this to generate):" -ForegroundColor Yellow
    Write-Host "     `$bytes = New-Object Byte[] 32; [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes(`$bytes); [Convert]::ToBase64String(`$bytes)" -ForegroundColor Cyan
    Write-Host ""
}

# Create necessary directories
Write-Host "Creating necessary directories..." -ForegroundColor Green
$directories = @(
    "services\tts-service\src\services",
    "services\stt-service\src\services",
    "services\chat-service\src\services",
    "services\document-reader\src\services",
    "services\quiz-service\src\services",
    "services\api-gateway\src",
    "data\kafka",
    "data\postgres",
    "data\redis"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}
Write-Host "✓ Directories created" -ForegroundColor Green
Write-Host ""

# Generate secrets
Write-Host "Generating secure secrets..." -ForegroundColor Green

# Generate JWT secret
$bytes = New-Object Byte[] 32
[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
$jwtSecret = [Convert]::ToBase64String($bytes)
Write-Host "JWT Secret (add to .env): $jwtSecret" -ForegroundColor Cyan

# Generate DB password
Add-Type -AssemblyName 'System.Web'
$dbPassword = [System.Web.Security.Membership]::GeneratePassword(16, 4)
Write-Host "DB Password (add to .env): $dbPassword" -ForegroundColor Cyan
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Setup complete! Next steps:" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Edit .env file with your configuration:" -ForegroundColor White
Write-Host "   notepad .env" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Start all services:" -ForegroundColor White
Write-Host "   docker-compose up -d" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Check service health:" -ForegroundColor White
Write-Host "   .\scripts\health-check.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. View logs:" -ForegroundColor White
Write-Host "   docker-compose logs -f" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Stop services:" -ForegroundColor White
Write-Host "   docker-compose down" -ForegroundColor Cyan
Write-Host ""
Write-Host "For AWS deployment, see: docs\guides\WINDOWS-SETUP-GUIDE.md" -ForegroundColor Yellow
Write-Host ""
