# Health Check Script for Windows
# Checks all services and their health endpoints

param(
    [string]$AlbDns = ""
)

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Health Check - All Services" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Function to check service health
function Test-ServiceHealth {
    param(
        [string]$ServiceName,
        [string]$Url
    )

    Write-Host "Checking $ServiceName... " -NoNewline

    try {
        $response = Invoke-WebRequest -Uri $Url -Method Get -TimeoutSec 5 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✓ Healthy" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✗ Unhealthy (HTTP $($response.StatusCode))" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "✗ Unreachable" -ForegroundColor Red
        return $false
    }
}

# Determine base URL
if ($AlbDns) {
    $baseUrl = "http://$AlbDns"
    Write-Host "Checking AWS services at $AlbDns..." -ForegroundColor Yellow
} else {
    $baseUrl = "http://localhost:8000"
    Write-Host "Checking local services..." -ForegroundColor Yellow
}

Write-Host ""

# Check API Gateway
$apiGatewayHealthy = Test-ServiceHealth "API Gateway" "$baseUrl/health"

# Check individual services
$services = @(
    @{Name="TTS Service"; Port=8001},
    @{Name="STT Service"; Port=8002},
    @{Name="Chat Service"; Port=8003},
    @{Name="Document Reader"; Port=8004},
    @{Name="Quiz Service"; Port=8005}
)

$allHealthy = $apiGatewayHealthy

foreach ($service in $services) {
    if ($AlbDns) {
        # On AWS, check through API Gateway
        $servicePath = $service.Name.Split(" ")[0].ToLower()
        $url = "$baseUrl/api/$servicePath/health"
    } else {
        # Locally, check direct port
        $url = "http://localhost:$($service.Port)/health"
    }

    $healthy = Test-ServiceHealth $service.Name $url
    $allHealthy = $allHealthy -and $healthy
}

Write-Host ""

# Check infrastructure services (local only)
if (-not $AlbDns) {
    Write-Host "Checking infrastructure services..." -ForegroundColor Yellow
    Write-Host ""

    # Check Kafka
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect("localhost", 9092)
        $tcpClient.Close()
        Write-Host "Checking Kafka... " -NoNewline
        Write-Host "✓ Running" -ForegroundColor Green
    } catch {
        Write-Host "Checking Kafka... " -NoNewline
        Write-Host "✗ Not accessible" -ForegroundColor Yellow
    }

    # Check PostgreSQL
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect("localhost", 5432)
        $tcpClient.Close()
        Write-Host "Checking PostgreSQL... " -NoNewline
        Write-Host "✓ Running" -ForegroundColor Green
    } catch {
        Write-Host "Checking PostgreSQL... " -NoNewline
        Write-Host "✗ Not accessible" -ForegroundColor Yellow
    }

    # Check Redis
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $tcpClient.Connect("localhost", 6379)
        $tcpClient.Close()
        Write-Host "Checking Redis... " -NoNewline
        Write-Host "✓ Running" -ForegroundColor Green
    } catch {
        Write-Host "Checking Redis... " -NoNewline
        Write-Host "✗ Not accessible" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
if ($allHealthy) {
    Write-Host "All services healthy! ✓" -ForegroundColor Green
} else {
    Write-Host "Some services are unhealthy" -ForegroundColor Yellow
}
Write-Host "================================" -ForegroundColor Cyan
