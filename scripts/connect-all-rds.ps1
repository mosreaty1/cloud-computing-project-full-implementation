# Connect to all RDS databases simultaneously
# Each database uses a different local port to avoid conflicts

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Setting up tunnels to ALL RDS databases" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

$databases = @(
    @{ name = "STT";      id = "learning-platform-stt-db-dev";      port = 5432 }
    @{ name = "Chat";     id = "learning-platform-chat-db-dev";     port = 5433 }
    @{ name = "Document"; id = "learning-platform-document-db-dev"; port = 5434 }
    @{ name = "Quiz";     id = "learning-platform-quiz-db-dev";     port = 5435 }
    @{ name = "User";     id = "learning-platform-user-db-dev";     port = 5436 }
)

Write-Host "Getting RDS endpoints..." -ForegroundColor Yellow
foreach ($db in $databases) {
    $endpoint = (aws rds describe-db-instances --db-instance-identifier $db.id --query "DBInstances[0].Endpoint.Address" --output text)
    $db.endpoint = $endpoint
    Write-Host "  $($db.name): $endpoint" -ForegroundColor White
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host "pgAdmin Connection Settings:" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Use these settings in pgAdmin:" -ForegroundColor Cyan
Write-Host ""

foreach ($db in $databases) {
    Write-Host "$($db.name) Database:" -ForegroundColor Yellow
    Write-Host "  Host:     localhost" -ForegroundColor White
    Write-Host "  Port:     $($db.port)" -ForegroundColor White
    Write-Host "  Username: dbadmin" -ForegroundColor White
    Write-Host "  Password: 44665544Mms" -ForegroundColor White
    Write-Host ""
}

Write-Host "==================================================" -ForegroundColor Yellow
Write-Host "Starting tunnels..." -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Yellow
Write-Host ""

# Start each tunnel in a new window
foreach ($db in $databases) {
    Write-Host "Starting tunnel for $($db.name)..." -ForegroundColor Cyan

    # Create parameters JSON
    $paramsFile = "$env:TEMP\ssm-params-$($db.name).json"
    $json = @"
{
    "portNumber": ["5432"],
    "localPortNumber": ["$($db.port)"],
    "host": ["$($db.endpoint)"]
}
"@
    $json | Out-File -FilePath $paramsFile -Encoding ASCII

    # Start tunnel in new window
    Start-Process powershell -ArgumentList "-NoExit", "-Command", @"
Write-Host '==================================================' -ForegroundColor Green
Write-Host 'Tunnel for $($db.name) Database' -ForegroundColor Green
Write-Host '==================================================' -ForegroundColor Green
Write-Host ''
Write-Host 'Local Port: $($db.port)' -ForegroundColor Yellow
Write-Host 'Remote: $($db.endpoint):5432' -ForegroundColor Yellow
Write-Host ''
Write-Host 'Keep this window open!' -ForegroundColor Red
Write-Host ''
aws ssm start-session --target i-0a834978ec5715681 --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters file://$paramsFile
Remove-Item '$paramsFile' -ErrorAction SilentlyContinue
"@

    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host "All tunnels started!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""
Write-Host "5 new windows opened - one for each database" -ForegroundColor Cyan
Write-Host "Keep all windows open while using pgAdmin" -ForegroundColor Yellow
Write-Host ""
Write-Host "Now add servers in pgAdmin using the settings shown above" -ForegroundColor White
