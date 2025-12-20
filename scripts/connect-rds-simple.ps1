# Simplified RDS Connection Script
# Creates SSH tunnel to RDS databases

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "RDS Connection via SSH Tunnel" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Get RDS endpoints from AWS (more reliable than terraform output)
Write-Host "Getting RDS endpoints..." -ForegroundColor Yellow
$sttEndpoint = (aws rds describe-db-instances --db-instance-identifier learning-platform-stt-db-dev --query "DBInstances[0].Endpoint.Address" --output text)
$chatEndpoint = (aws rds describe-db-instances --db-instance-identifier learning-platform-chat-db-dev --query "DBInstances[0].Endpoint.Address" --output text)
$documentEndpoint = (aws rds describe-db-instances --db-instance-identifier learning-platform-document-db-dev --query "DBInstances[0].Endpoint.Address" --output text)
$quizEndpoint = (aws rds describe-db-instances --db-instance-identifier learning-platform-quiz-db-dev --query "DBInstances[0].Endpoint.Address" --output text)
$userEndpoint = (aws rds describe-db-instances --db-instance-identifier learning-platform-user-db-dev --query "DBInstances[0].Endpoint.Address" --output text)

# Select database
Write-Host "Select database:" -ForegroundColor Yellow
Write-Host "1. STT" -ForegroundColor White
Write-Host "2. Chat" -ForegroundColor White
Write-Host "3. Document" -ForegroundColor White
Write-Host "4. Quiz" -ForegroundColor White
Write-Host "5. User" -ForegroundColor White
$choice = Read-Host "`nChoice (1-5)"

$databases = @{
    "1" = @{ name = "STT"; endpoint = $sttEndpoint }
    "2" = @{ name = "Chat"; endpoint = $chatEndpoint }
    "3" = @{ name = "Document"; endpoint = $documentEndpoint }
    "4" = @{ name = "Quiz"; endpoint = $quizEndpoint }
    "5" = @{ name = "User"; endpoint = $userEndpoint }
}

$db = $databases[$choice]
$rdsHost = $db.endpoint -replace ":5432", ""

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host "Connecting to $($db.name) database" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Creating tunnel..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Once connected, use pgAdmin with these settings:" -ForegroundColor Cyan
Write-Host "  Host:     localhost" -ForegroundColor White
Write-Host "  Port:     5432" -ForegroundColor White
Write-Host "  Username: dbadmin" -ForegroundColor White
Write-Host "  Password: 44665544Mms" -ForegroundColor White
Write-Host ""
Write-Host "Keep this window open! Press Ctrl+C to stop." -ForegroundColor Yellow
Write-Host ""

# Create parameters JSON file
$paramsFile = "$env:TEMP\ssm-params.json"
$json = @"
{
    "portNumber": ["5432"],
    "localPortNumber": ["5432"],
    "host": ["$rdsHost"]
}
"@

$json | Out-File -FilePath $paramsFile -Encoding ASCII

# Start the tunnel (using Kafka broker which is SSM-connected)
aws ssm start-session `
    --target i-0a834978ec5715681 `
    --document-name AWS-StartPortForwardingSessionToRemoteHost `
    --parameters file://$paramsFile

# Cleanup
Remove-Item $paramsFile -ErrorAction SilentlyContinue
