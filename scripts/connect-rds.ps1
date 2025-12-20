# RDS Connection via SSH Tunnel Script
# This script creates an SSH tunnel through your EC2 instance to access RDS

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "RDS SSH Tunnel Setup" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Get RDS endpoints
cd C:\Users\Bedaya\Downloads\cloud-computing-project-full-implementation\infrastructure\environments\dev
$endpoints = terraform output -json rds_endpoints | ConvertFrom-Json

# Container host instance ID
$instanceId = "i-04c59abc3770439f8"

# Database selection
Write-Host "Select database to connect to:" -ForegroundColor Yellow
Write-Host "1. STT Service" -ForegroundColor White
Write-Host "2. Chat Service" -ForegroundColor White
Write-Host "3. Document Service" -ForegroundColor White
Write-Host "4. Quiz Service" -ForegroundColor White
Write-Host "5. User Service" -ForegroundColor White
Write-Host ""
$choice = Read-Host "Enter choice (1-5)"

$dbMap = @{
    "1" = @{ "name" = "STT"; "endpoint" = $endpoints.stt }
    "2" = @{ "name" = "Chat"; "endpoint" = $endpoints.chat }
    "3" = @{ "name" = "Document"; "endpoint" = $endpoints.document }
    "4" = @{ "name" = "Quiz"; "endpoint" = $endpoints.quiz }
    "5" = @{ "name" = "User"; "endpoint" = $endpoints.user }
}

$selected = $dbMap[$choice]
$rdsHost = $selected.endpoint -replace ":5432", ""
$localPort = 5432

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host "Creating tunnel to $($selected.name) database..." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""
Write-Host "RDS Endpoint: $rdsHost" -ForegroundColor White
Write-Host "Local Port:   $localPort" -ForegroundColor White
Write-Host ""
Write-Host "Once connected, use these pgAdmin settings:" -ForegroundColor Yellow
Write-Host "  Host:     localhost" -ForegroundColor White
Write-Host "  Port:     $localPort" -ForegroundColor White
Write-Host "  Username: dbadmin" -ForegroundColor White
Write-Host "  Password: YourSecurePassword123!" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop the tunnel" -ForegroundColor Yellow
Write-Host ""

# Create the tunnel
aws ssm start-session `
    --target $instanceId `
    --document-name AWS-StartPortForwardingSessionToRemoteHost `
    --parameters "{`"portNumber`":[`"5432`"],`"localPortNumber`":[`"$localPort`"],`"host`":[`"$rdsHost`"]}"
