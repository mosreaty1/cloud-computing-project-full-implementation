# Allow pgAdmin access to RDS from your IP address

Write-Host "Getting your public IP address..." -ForegroundColor Cyan
$myIp = (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
Write-Host "Your IP: $myIp" -ForegroundColor Green

Write-Host "`nGetting RDS security group..." -ForegroundColor Cyan
$sgId = (aws ec2 describe-security-groups --filters "Name=tag:Name,Values=*rds*" --query "SecurityGroups[0].GroupId" --output text)

if ($sgId -eq "None" -or [string]::IsNullOrEmpty($sgId)) {
    Write-Host "ERROR: Could not find RDS security group" -ForegroundColor Red
    Write-Host "Please find it manually in AWS Console: EC2 > Security Groups" -ForegroundColor Yellow
    exit 1
}

Write-Host "RDS Security Group: $sgId" -ForegroundColor Green

Write-Host "`nAdding rule to allow PostgreSQL access from your IP..." -ForegroundColor Cyan
try {
    aws ec2 authorize-security-group-ingress `
        --group-id $sgId `
        --protocol tcp `
        --port 5432 `
        --cidr "$myIp/32" `
        --description "pgAdmin access from my workstation"

    Write-Host "SUCCESS! Security group rule added." -ForegroundColor Green
    Write-Host "`nYou can now connect to RDS from pgAdmin!" -ForegroundColor Green
} catch {
    if ($_.Exception.Message -like "*already exists*") {
        Write-Host "Rule already exists - you're good to go!" -ForegroundColor Yellow
    } else {
        Write-Host "ERROR: $_" -ForegroundColor Red
        Write-Host "`nManual Steps:" -ForegroundColor Yellow
        Write-Host "1. Go to AWS Console > EC2 > Security Groups" -ForegroundColor White
        Write-Host "2. Find security group: $sgId" -ForegroundColor White
        Write-Host "3. Edit Inbound Rules > Add Rule" -ForegroundColor White
        Write-Host "4. Type: PostgreSQL, Port: 5432, Source: My IP ($myIp/32)" -ForegroundColor White
    }
}

Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "pgAdmin Configuration Instructions:" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "In pgAdmin, on the Connection tab:" -ForegroundColor White
Write-Host "1. SCROLL DOWN below the password field" -ForegroundColor Yellow
Write-Host "2. Find 'SSL mode' dropdown" -ForegroundColor Yellow
Write-Host "3. Set it to: prefer" -ForegroundColor Green
Write-Host "4. Click Save" -ForegroundColor Yellow
Write-Host "`nThe SSL mode is on the same Connection tab, just scroll down!" -ForegroundColor Cyan
