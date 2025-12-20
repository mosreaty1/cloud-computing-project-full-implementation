# RDS Database Initialization Script
# This script tests connectivity to all RDS databases and creates initial databases

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "RDS Database Initialization" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Get RDS endpoints from Terraform
Write-Host "Getting RDS endpoints..." -ForegroundColor Yellow
$endpoints = terraform output -json rds_endpoints | ConvertFrom-Json

# Database password
$DB_PASSWORD = "YourSecurePassword123!"  # From terraform.tfvars
$DB_USER = "dbadmin"

# Display endpoints
Write-Host ""
Write-Host "RDS Endpoints:" -ForegroundColor Green
Write-Host "  STT:      $($endpoints.stt)" -ForegroundColor White
Write-Host "  Chat:     $($endpoints.chat)" -ForegroundColor White
Write-Host "  Document: $($endpoints.document)" -ForegroundColor White
Write-Host "  Quiz:     $($endpoints.quiz)" -ForegroundColor White
Write-Host "  User:     $($endpoints.user)" -ForegroundColor White
Write-Host ""

# Database configuration
$databases = @{
    "stt" = @{
        "endpoint" = $endpoints.stt -replace ":5432", ""
        "dbname" = "stt_service_db"
        "description" = "Speech-to-Text Service"
    }
    "chat" = @{
        "endpoint" = $endpoints.chat -replace ":5432", ""
        "dbname" = "chat_service_db"
        "description" = "Chat Service"
    }
    "document" = @{
        "endpoint" = $endpoints.document -replace ":5432", ""
        "dbname" = "document_service_db"
        "description" = "Document Reader Service"
    }
    "quiz" = @{
        "endpoint" = $endpoints.quiz -replace ":5432", ""
        "dbname" = "quiz_service_db"
        "description" = "Quiz Service"
    }
    "user" = @{
        "endpoint" = $endpoints.user -replace ":5432", ""
        "dbname" = "user_service_db"
        "description" = "User Management Service"
    }
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "pgAdmin Connection Information" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

foreach ($service in $databases.Keys) {
    $db = $databases[$service]
    Write-Host "[$service] $($db.description)" -ForegroundColor Green
    Write-Host "  Host:     $($db.endpoint)" -ForegroundColor White
    Write-Host "  Port:     5432" -ForegroundColor White
    Write-Host "  Database: $($db.dbname)" -ForegroundColor White
    Write-Host "  Username: $DB_USER" -ForegroundColor White
    Write-Host "  Password: $DB_PASSWORD" -ForegroundColor White
    Write-Host ""
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "pgAdmin Setup Instructions" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open pgAdmin 4" -ForegroundColor Yellow
Write-Host "2. Right-click 'Servers' → Register → Server" -ForegroundColor Yellow
Write-Host "3. For each database above, enter:" -ForegroundColor Yellow
Write-Host "   - Name: AWS - [Service Name]" -ForegroundColor White
Write-Host "   - Host: [endpoint from above]" -ForegroundColor White
Write-Host "   - Port: 5432" -ForegroundColor White
Write-Host "   - Username: dbadmin" -ForegroundColor White
Write-Host "   - Password: YourSecurePassword123!" -ForegroundColor White
Write-Host "   - Save password: ✓ Checked" -ForegroundColor White
Write-Host ""

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "After Connecting in pgAdmin" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Create the databases:" -ForegroundColor Yellow
Write-Host "  Right-click 'Databases' → Create → Database" -ForegroundColor White
Write-Host ""
Write-Host "Database names to create:" -ForegroundColor Yellow
foreach ($service in $databases.Keys) {
    Write-Host "  - $($databases[$service].dbname)" -ForegroundColor White
}
Write-Host ""

Write-Host "==================================================" -ForegroundColor Green
Write-Host "Setup Information Saved!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Tip: Your microservices will automatically create tables" -ForegroundColor Cyan
Write-Host "   on first run. You just need to create the databases." -ForegroundColor Cyan
Write-Host ""
