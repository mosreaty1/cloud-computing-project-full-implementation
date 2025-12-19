# Cloud-Based Learning Platform - Windows Setup Guide

Complete guide for setting up and deploying the Cloud-Based Learning Platform on Windows.

## 📋 Table of Contents

1. [Prerequisites for Windows](#prerequisites-for-windows)
2. [Installing Required Tools](#installing-required-tools)
3. [AWS Account Setup](#aws-account-setup)
4. [Local Development on Windows](#local-development-on-windows)
5. [AWS Deployment from Windows](#aws-deployment-from-windows)
6. [Troubleshooting Windows Issues](#troubleshooting-windows-issues)

## Prerequisites for Windows

### System Requirements
- **Windows 10/11** (64-bit)
- **8GB RAM** minimum (16GB recommended)
- **50GB free disk space**
- **Administrator access**

## Installing Required Tools

### Step 1: Install Git for Windows

1. Download Git from: https://git-scm.com/download/win
2. Run the installer
3. **Important**: Select "Git Bash" during installation
4. Use default settings

**Verify installation:**
```powershell
git --version
```

### Step 2: Install Docker Desktop for Windows

1. Download from: https://www.docker.com/products/docker-desktop/
2. Run installer as Administrator
3. Enable WSL 2 backend when prompted
4. Restart your computer

**Verify installation:**
```powershell
docker --version
docker-compose --version
```

### Step 3: Install AWS CLI for Windows

**Option A: Using MSI Installer (Recommended)**

1. Download from: https://awscli.amazonaws.com/AWSCLIV2.msi
2. Run the MSI installer
3. Follow installation wizard
4. Click Finish

**Option B: Using PowerShell**

```powershell
# Download installer
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile "$env:TEMP\AWSCLIV2.msi"

# Install
Start-Process msiexec.exe -ArgumentList "/i $env:TEMP\AWSCLIV2.msi /quiet" -Wait
```

**Verify installation:**
```powershell
aws --version
```

### Step 4: Install Terraform for Windows

**Option A: Using Chocolatey (Easy)**

```powershell
# Install Chocolatey first (run as Administrator)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Terraform
choco install terraform -y
```

**Option B: Manual Installation**

1. Download from: https://www.terraform.io/downloads
2. Extract `terraform.exe` from the ZIP file
3. Move to `C:\terraform\`
4. Add to PATH:
   - Press `Win + X`, select "System"
   - Click "Advanced system settings"
   - Click "Environment Variables"
   - Under "System variables", find "Path"
   - Click "Edit" → "New"
   - Add `C:\terraform`
   - Click OK on all dialogs

**Verify installation:**
```powershell
terraform --version
```

### Step 5: Install Python (for running services locally)

1. Download from: https://www.python.org/downloads/
2. **Important**: Check "Add Python to PATH" during installation
3. Run installer

**Verify installation:**
```powershell
python --version
pip --version
```

### Step 6: Install kubectl (Optional, for Kubernetes)

```powershell
# Using Chocolatey
choco install kubernetes-cli -y

# OR download manually from:
# https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
```

**Verify installation:**
```powershell
kubectl version --client
```

### Step 7: Install Visual Studio Code (Optional but Recommended)

1. Download from: https://code.visualstudio.com/
2. Run installer
3. Recommended extensions:
   - Docker
   - Terraform
   - Python
   - PowerShell

## AWS Account Setup

### Step 1: Create AWS Account

1. Go to: https://aws.amazon.com
2. Click "Create an AWS Account"
3. Follow the registration process
4. Add payment method
5. Verify email and phone

### Step 2: Create IAM User

1. Login to AWS Console: https://console.aws.amazon.com
2. Search for "IAM" in services
3. Click "Users" → "Add users"
4. User name: `terraform-admin`
5. Select "Access key - Programmatic access"
6. Click "Next: Permissions"
7. Select "Attach existing policies directly"
8. Search and select: `AdministratorAccess`
9. Click "Next" until "Create user"
10. **IMPORTANT**: Download the CSV with Access Key ID and Secret Access Key

### Step 3: Configure AWS CLI

Open PowerShell and run:

```powershell
aws configure
```

Enter when prompted:
```
AWS Access Key ID: [paste from CSV]
AWS Secret Access Key: [paste from CSV]
Default region name: us-east-1
Default output format: json
```

**Verify configuration:**
```powershell
aws sts get-caller-identity
```

You should see your account information.

## Local Development on Windows

### Step 1: Clone Repository

```powershell
# Open PowerShell
cd C:\
git clone <repository-url>
cd cloud-computing-project-full-implementation
```

### Step 2: Setup Environment

```powershell
# Copy environment template
Copy-Item .env.example .env

# Edit .env file
notepad .env
```

**Required environment variables:**
```ini
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=123456789012
ENVIRONMENT=dev

# OpenAI API Key (get from https://platform.openai.com/api-keys)
OPENAI_API_KEY=sk-your-key-here

# JWT Secret (generate random string)
JWT_SECRET=your-random-secret-key-here

# Database password
DB_PASSWORD=SecurePassword123!
```

**Generate secure secrets:**
```powershell
# Generate random JWT secret
$bytes = New-Object Byte[] 32
[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
[Convert]::ToBase64String($bytes)

# Generate database password
Add-Type -AssemblyName 'System.Web'
[System.Web.Security.Membership]::GeneratePassword(16, 4)
```

### Step 3: Start Services with Docker

Make sure Docker Desktop is running!

```powershell
# Start all services
docker-compose up -d

# Wait 2-3 minutes for services to initialize

# Check running containers
docker-compose ps
```

### Step 4: Verify Services

```powershell
# Check API Gateway
curl http://localhost:8000/health

# Check TTS Service
curl http://localhost:8001/health

# Check all services
.\scripts\health-check.ps1
```

### Step 5: View Logs

```powershell
# View all logs
docker-compose logs -f

# View specific service
docker-compose logs -f tts-service

# View API Gateway
docker-compose logs -f api-gateway
```

### Step 6: Test API

```powershell
# Test Text-to-Speech
$body = @{
    text = "Hello from Windows"
    language = "en"
    user_id = "test-user"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/api/tts/synthesize" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body
```

### Stop Services

```powershell
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

## AWS Deployment from Windows

### Step 1: Prepare Terraform Variables

```powershell
cd infrastructure\environments\dev

# Copy example file
Copy-Item terraform.tfvars.example terraform.tfvars

# Edit with your values
notepad terraform.tfvars
```

**terraform.tfvars content:**
```hcl
aws_region   = "us-east-1"
project_name = "learning-platform"
environment  = "dev"
vpc_cidr     = "10.0.0.0/16"

# Use the password from .env
db_username = "dbadmin"
db_password = "SecurePassword123!"
```

### Step 2: Initialize Terraform

```powershell
# Still in infrastructure\environments\dev
terraform init

# Should see: "Terraform has been successfully initialized!"
```

### Step 3: Plan Infrastructure

```powershell
# Review what will be created
terraform plan -out=tfplan

# Review the plan carefully
# Check resources, costs, etc.
```

### Step 4: Deploy Infrastructure

```powershell
# Apply the plan (this will create AWS resources)
terraform apply tfplan

# Type 'yes' when prompted
# This takes 20-30 minutes
```

### Step 5: Save Outputs

```powershell
# Save important outputs
terraform output | Out-File ..\..\..\terraform-outputs.txt

# View specific outputs
terraform output alb_dns_name
terraform output kafka_broker_ips
terraform output ecr_repositories
```

### Step 6: Build and Push Docker Images

First, login to ECR:

```powershell
# Get AWS account ID
$AWS_ACCOUNT_ID = (aws sts get-caller-identity --query Account --output text)
$AWS_REGION = "us-east-1"
$ECR_REGISTRY = "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
```

Run the build script:

```powershell
cd ..\..\..\  # Back to project root

# Run PowerShell build script
.\scripts\build-and-push.ps1
```

### Step 7: Deploy Services

```powershell
# Deploy using PowerShell script
.\scripts\deploy-services.ps1 -Environment dev
```

### Step 8: Verify Deployment

```powershell
# Get ALB DNS name
$ALB_DNS = (terraform output -raw alb_dns_name)

# Check health
Invoke-RestMethod -Uri "http://$ALB_DNS/health"

# Check all services
.\scripts\health-check.ps1 -AlbDns $ALB_DNS
```

## Troubleshooting Windows Issues

### Issue: "docker-compose: command not found"

**Solution:**
```powershell
# Make sure Docker Desktop is running
# Check if it's installed
docker-compose --version

# If not found, reinstall Docker Desktop
```

### Issue: "aws: command not found"

**Solution:**
```powershell
# Close and reopen PowerShell
# Or add to PATH manually
$env:Path += ";C:\Program Files\Amazon\AWSCLIV2"

# Verify
aws --version
```

### Issue: "Terraform not found"

**Solution:**
```powershell
# Add to PATH
$env:Path += ";C:\terraform"

# Or reinstall using Chocolatey
choco install terraform -y
```

### Issue: "Docker Error: no such file or directory"

**Solution:**
```powershell
# Enable WSL 2
wsl --install

# Restart computer
# Start Docker Desktop
# Go to Settings → General → Use WSL 2 based engine
```

### Issue: "Port already in use"

**Solution:**
```powershell
# Find process using port 8000
netstat -ano | findstr :8000

# Kill process (replace PID with actual process ID)
taskkill /PID <PID> /F

# Or change port in docker-compose.yml
```

### Issue: "Cannot connect to Docker daemon"

**Solution:**
1. Open Docker Desktop
2. Wait for it to start (whale icon in system tray)
3. Try command again

### Issue: "Access Denied" errors

**Solution:**
```powershell
# Run PowerShell as Administrator
# Right-click PowerShell → Run as Administrator
```

### Issue: "AWS credentials not configured"

**Solution:**
```powershell
# Check credentials
aws configure list

# Reconfigure if needed
aws configure

# Check if working
aws sts get-caller-identity
```

### Issue: Line Ending Problems (Git)

**Solution:**
```powershell
# Configure Git for Windows
git config --global core.autocrlf true
git config --global core.eol lf
```

## Windows-Specific Tips

### Use PowerShell, Not CMD
Always use PowerShell (not Command Prompt) for better compatibility.

### File Paths
Use backslashes (`\`) in Windows or forward slashes (`/`) - both work:
```powershell
cd C:\project\infrastructure
# OR
cd C:/project/infrastructure
```

### Environment Variables
```powershell
# Set environment variable
$env:AWS_REGION = "us-east-1"

# View environment variable
echo $env:AWS_REGION

# Permanent (add to PowerShell profile)
notepad $PROFILE
# Add: $env:AWS_REGION = "us-east-1"
```

### Running Scripts
```powershell
# Enable script execution (run once as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run PowerShell script
.\scripts\setup-local.ps1
```

### Docker Volumes on Windows
Docker volumes are stored in WSL 2:
```powershell
# Access via
\\wsl$\docker-desktop-data\version-pack-data\community\docker\volumes
```

## Quick Reference Commands

### Docker
```powershell
docker-compose up -d              # Start services
docker-compose down               # Stop services
docker-compose ps                 # List containers
docker-compose logs -f            # View logs
docker system prune -a            # Clean up Docker
```

### AWS
```powershell
aws configure                     # Setup credentials
aws sts get-caller-identity       # Verify credentials
aws s3 ls                         # List S3 buckets
aws ec2 describe-instances        # List EC2 instances
```

### Terraform
```powershell
terraform init                    # Initialize
terraform plan                    # Plan changes
terraform apply                   # Apply changes
terraform destroy                 # Destroy infrastructure
terraform output                  # Show outputs
```

### Git
```powershell
git clone <url>                   # Clone repository
git status                        # Check status
git add .                         # Stage all changes
git commit -m "message"           # Commit
git push                          # Push to remote
```

## Next Steps

1. ✅ Tools installed
2. ✅ AWS configured
3. ✅ Services running locally

Now proceed to:
- **Test locally**: Use the API endpoints
- **Deploy to AWS**: Follow the deployment steps above
- **Monitor**: Check CloudWatch logs
- **Customize**: Modify services for your needs

## Support

For Windows-specific issues:
1. Check Docker Desktop is running
2. Run PowerShell as Administrator
3. Check firewall/antivirus settings
4. Review error messages in logs
5. See [Troubleshooting Guide](TROUBLESHOOTING-WINDOWS.md)

---

**All commands in this guide are tested on Windows 10/11!** 🪟
