# PowerShell script to set up Kafka topics via SSM
# This script uploads the bash script to the Kafka broker and executes it

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Kafka Topics Setup via SSM Session Manager" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Get Kafka broker instance ID
$kafkaInstanceId = "i-0a834978ec5715681"

Write-Host "Step 1: Uploading setup script to Kafka broker..." -ForegroundColor Yellow

# Read the bash script
$scriptPath = "$PSScriptRoot\setup-kafka-topics.sh"
if (-not (Test-Path $scriptPath)) {
    Write-Host "Error: Script not found at $scriptPath" -ForegroundColor Red
    exit 1
}

$scriptContent = Get-Content $scriptPath -Raw

# Create a temporary file on the instance and execute it
$commands = @"
#!/bin/bash
# Write the script
cat > /tmp/setup-kafka-topics.sh << 'SCRIPT_EOF'
$scriptContent
SCRIPT_EOF

# Make it executable
chmod +x /tmp/setup-kafka-topics.sh

# Execute it
bash /tmp/setup-kafka-topics.sh

# Clean up
rm /tmp/setup-kafka-topics.sh
"@

# Save commands to a temporary file
$tempCommandFile = [System.IO.Path]::GetTempFileName()
$commands | Out-File -FilePath $tempCommandFile -Encoding ASCII

Write-Host "Step 2: Executing setup script on Kafka broker..." -ForegroundColor Yellow
Write-Host ""

# Send command via SSM
try {
    $result = aws ssm send-command `
        --instance-ids $kafkaInstanceId `
        --document-name "AWS-RunShellScript" `
        --parameters "commands=@$tempCommandFile" `
        --output json | ConvertFrom-Json

    $commandId = $result.Command.CommandId
    Write-Host "Command sent! Command ID: $commandId" -ForegroundColor Green
    Write-Host ""
    Write-Host "Waiting for command to complete..." -ForegroundColor Yellow

    # Wait for command to complete
    Start-Sleep -Seconds 5

    # Get command output
    $output = aws ssm get-command-invocation `
        --command-id $commandId `
        --instance-id $kafkaInstanceId `
        --output json | ConvertFrom-Json

    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host "Command Output:" -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Green
    Write-Host $output.StandardOutputContent

    if ($output.StandardErrorContent) {
        Write-Host ""
        Write-Host "==================================================" -ForegroundColor Yellow
        Write-Host "Errors/Warnings:" -ForegroundColor Yellow
        Write-Host "==================================================" -ForegroundColor Yellow
        Write-Host $output.StandardErrorContent
    }

} catch {
    Write-Host "Error executing command: $_" -ForegroundColor Red
} finally {
    # Clean up temp file
    Remove-Item $tempCommandFile -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Verify topics were created" -ForegroundColor Yellow
Write-Host "2. Test Kafka by producing/consuming messages" -ForegroundColor Yellow
Write-Host "3. Deploy your microservices" -ForegroundColor Yellow
