# Complete AWS Deployment Guide for Windows

**Deploy the Cloud-Based Learning Platform to AWS from Windows - Step by Step**

## 📋 Table of Contents

1. [AWS Account Setup](#1-aws-account-setup)
2. [AWS CLI Installation & Configuration](#2-aws-cli-installation--configuration)
3. [Install Terraform](#3-install-terraform)
4. [Prepare Your Project](#4-prepare-your-project)
5. [Deploy Infrastructure with Terraform](#5-deploy-infrastructure-with-terraform)
6. [Configure Kafka Cluster](#6-configure-kafka-cluster)
7. [Setup RDS Databases](#7-setup-rds-databases)
8. [Build and Push Docker Images](#8-build-and-push-docker-images)
9. [Deploy Microservices](#9-deploy-microservices)
10. [Verify Deployment](#10-verify-deployment)
11. [Configure DNS (Optional)](#11-configure-dns-optional)
12. [Monitoring & Logging](#12-monitoring--logging)
13. [Cost Management](#13-cost-management)
14. [Troubleshooting](#14-troubleshooting)
15. [Tear Down (When Done)](#15-tear-down-when-done)

---

## 1. AWS Account Setup

### Step 1.1: Create AWS Account

1. **Go to AWS Homepage**
   - Visit: https://aws.amazon.com
   - Click **"Create an AWS Account"** (top right)

2. **Fill in Account Details**
   ```
   Email: your-email@example.com
   Password: Create strong password
   AWS Account Name: learning-platform-dev
   ```
   - Click **Continue**

3. **Contact Information**
   - Select: **Personal** or **Business**
   - Fill in:
     - Full Name
     - Phone Number
     - Country
     - Address
   - Click **Continue**

4. **Payment Information**
   - Enter credit/debit card details
   - Note: AWS offers Free Tier, but requires payment method
   - Click **Verify and Continue**

5. **Confirm Identity**
   - Select: **Text message (SMS)** or **Voice call**
   - Enter verification code
   - Click **Continue**

6. **Select Support Plan**
   - Choose: **Basic Plan (Free)**
   - Click **Complete sign up**

7. **Wait for Account Activation**
   - Usually takes 5-10 minutes
   - You'll receive email when ready

### Step 1.2: Sign in to AWS Console

1. Go to: https://console.aws.amazon.com
2. Click **"Sign in to the Console"**
3. Select: **Root user**
4. Enter email and password
5. You're in the AWS Console!

### Step 1.3: Enable MFA (Highly Recommended)

1. In AWS Console, click your name (top right) → **Security credentials**
2. Under **Multi-factor authentication (MFA)**, click **Assign MFA device**
3. Select **Virtual MFA device**
4. Use app like:
   - **Microsoft Authenticator** (Windows/Android/iOS)
   - **Google Authenticator** (Android/iOS)
   - **Authy** (Windows/Mac/Linux)
5. Scan QR code with app
6. Enter two consecutive MFA codes
7. Click **Assign MFA**

---

## 2. AWS CLI Installation & Configuration

### Step 2.1: Install AWS CLI on Windows

**Option A: MSI Installer (Recommended)**

1. **Download AWS CLI**
   - Go to: https://awscli.amazonaws.com/AWSCLIV2.msi
   - Save the MSI file

2. **Run Installer**
   - Double-click `AWSCLIV2.msi`
   - Click **Next** → **Next** → **Install**
   - Click **Finish**

3. **Verify Installation**
   ```powershell
   # Open PowerShell
   aws --version
   # Should show: aws-cli/2.x.x Python/3.x.x Windows/...
   ```

**Option B: PowerShell Installation**

```powershell
# Download installer
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri "https://awscli.amazonaws.com/AWSCLIV2.msi" -OutFile "$env:TEMP\AWSCLIV2.msi"

# Install silently
Start-Process msiexec.exe -ArgumentList "/i $env:TEMP\AWSCLIV2.msi /quiet" -Wait

# Add to PATH (close and reopen PowerShell after)
$env:Path += ";C:\Program Files\Amazon\AWSCLIV2"

# Verify
aws --version
```

### Step 2.2: Create IAM User for Deployment

**Why?** Don't use root account for everyday tasks - create IAM user instead.

1. **Open IAM Console**
   - AWS Console → Search **"IAM"** → Click **IAM**

2. **Create User**
   - Left sidebar → **Users** → **Add users**
   - User name: `terraform-admin`
   - Select: ✅ **Access key - Programmatic access**
   - Click **Next: Permissions**

3. **Set Permissions**
   - Select: **Attach existing policies directly**
   - Search and check:
     - ✅ `AdministratorAccess`
   - Click **Next: Tags**

4. **Add Tags (Optional)**
   - Key: `Purpose`, Value: `Terraform Deployment`
   - Click **Next: Review**

5. **Review and Create**
   - Review details
   - Click **Create user**

6. **IMPORTANT: Save Credentials**
   - Click **Download .csv** button
   - **Save this file securely!**
   - You'll see:
     ```
     Access Key ID: AKIAIOSFODNN7EXAMPLE
     Secret Access Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
     ```
   - Click **Close**

### Step 2.3: Configure AWS CLI

```powershell
# Run configuration
aws configure

# You'll be prompted - enter these:
```

**Prompts and Answers:**
```
AWS Access Key ID [None]: PASTE_YOUR_ACCESS_KEY_ID
AWS Secret Access Key [None]: PASTE_YOUR_SECRET_ACCESS_KEY
Default region name [None]: us-east-1
Default output format [None]: json
```

**Verify Configuration:**
```powershell
# Test AWS credentials
aws sts get-caller-identity

# Should show:
# {
#     "UserId": "AIDAI...",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/terraform-admin"
# }
```

**Alternative: Configure with Profile**
```powershell
# Create named profile
aws configure --profile learning-platform

# Use profile
$env:AWS_PROFILE = "learning-platform"
aws sts get-caller-identity
```

---

## 3. Install Terraform

### Step 3.1: Install Terraform on Windows

**Option A: Using Chocolatey (Easiest)**

```powershell
# Install Chocolatey first (if not installed)
# Run PowerShell as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Terraform
choco install terraform -y

# Verify
terraform --version
# Should show: Terraform v1.6.x
```

**Option B: Manual Installation**

1. **Download Terraform**
   - Go to: https://www.terraform.io/downloads
   - Download: **Windows AMD64** (zip file)

2. **Extract and Install**
   ```powershell
   # Create directory
   New-Item -ItemType Directory -Force -Path C:\terraform

   # Extract terraform.exe to C:\terraform\
   # (Use Windows Explorer to extract the ZIP)
   ```

3. **Add to PATH**
   ```powershell
   # Add to PATH permanently
   [Environment]::SetEnvironmentVariable(
       "Path",
       [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\terraform",
       "User"
   )

   # Close and reopen PowerShell
   ```

4. **Verify Installation**
   ```powershell
   terraform --version
   ```

---

## 4. Prepare Your Project

### Step 4.1: Clone Project

```powershell
# Navigate to your preferred location
cd C:\

# Clone repository
git clone <repository-url>
cd cloud-computing-project-full-implementation
```

### Step 4.2: Configure Environment Variables

```powershell
# Copy example file
Copy-Item .env.example .env

# Edit with your details
notepad .env
```

**Required Variables in .env:**
```ini
# AWS Configuration
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=123456789012  # Replace with your account ID

# Environment
ENVIRONMENT=dev

# OpenAI API Key (get from https://platform.openai.com/api-keys)
OPENAI_API_KEY=sk-your-actual-key-here

# JWT Secret (generate random string)
JWT_SECRET=your-secure-jwt-secret-here

# Database Password (use strong password)
DB_PASSWORD=YourSecureDBPassword123!

# S3 Bucket Names (auto-generated, just verify)
TTS_BUCKET=learning-platform-tts-service-storage-dev
STT_BUCKET=learning-platform-stt-service-storage-dev
CHAT_BUCKET=learning-platform-chat-service-storage-dev
DOCUMENT_BUCKET=learning-platform-document-reader-storage-dev
QUIZ_BUCKET=learning-platform-quiz-service-storage-dev
```

**Generate Secure Secrets:**
```powershell
# Generate JWT Secret
$bytes = New-Object Byte[] 32
[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
$jwtSecret = [Convert]::ToBase64String($bytes)
Write-Host "JWT_SECRET=$jwtSecret"

# Generate DB Password
Add-Type -AssemblyName 'System.Web'
$dbPassword = [System.Web.Security.Membership]::GeneratePassword(16, 4)
Write-Host "DB_PASSWORD=$dbPassword"

# Get AWS Account ID
$accountId = (aws sts get-caller-identity --query Account --output text)
Write-Host "AWS_ACCOUNT_ID=$accountId"
```

Save these values in your `.env` file.

### Step 4.3: Configure Terraform Variables

```powershell
# Navigate to Terraform dev environment
cd infrastructure\environments\dev

# Copy example file
Copy-Item terraform.tfvars.example terraform.tfvars

# Edit with your values
notepad terraform.tfvars
```

**terraform.tfvars content:**
```hcl
# AWS Configuration
aws_region   = "us-east-1"
project_name = "learning-platform"
environment  = "dev"

# Network Configuration
vpc_cidr = "10.0.0.0/16"

# Database Configuration
db_username = "dbadmin"
db_password = "YourSecureDBPassword123!"  # Same as in .env
```

---

## 5. Deploy Infrastructure with Terraform

### Step 5.1: Initialize Terraform

```powershell
# Make sure you're in infrastructure/environments/dev
cd C:\cloud-computing-project-full-implementation\infrastructure\environments\dev

# Initialize Terraform
terraform init

# You should see:
# Terraform has been successfully initialized!
```

**What this does:**
- Downloads required providers (AWS)
- Sets up backend
- Prepares modules

### Step 5.2: Validate Configuration

```powershell
# Validate Terraform files
terraform validate

# Should show: Success! The configuration is valid.
```

### Step 5.3: Plan Infrastructure

```powershell
# Create execution plan
terraform plan -out=tfplan

# This will show you:
# - Resources to be created
# - Estimated costs
# - Changes to be made
```

**Review the Plan:**
Look for these resources being created:
- ✅ VPC and Subnets
- ✅ EC2 Instances (Kafka, Zookeeper, Container Hosts)
- ✅ RDS Databases (5 instances)
- ✅ S3 Buckets (6 buckets)
- ✅ Load Balancers (ALB + NLB)
- ✅ Security Groups
- ✅ IAM Roles

**Example Output:**
```
Plan: 87 to add, 0 to change, 0 to destroy.
```

### Step 5.4: Apply Infrastructure

```powershell
# Apply the plan
terraform apply tfplan

# ⏰ This takes 20-30 minutes
# Go get coffee! ☕
```

**What's Happening:**
1. Creating VPC and networking (2-3 min)
2. Creating security groups (1 min)
3. Launching EC2 instances (5-7 min)
4. Creating RDS databases (15-20 min) ⏰ Longest part
5. Setting up load balancers (2-3 min)
6. Creating S3 buckets (1 min)

**Progress Indicators:**
```
aws_vpc.main: Creating...
aws_vpc.main: Creation complete after 2s
aws_subnet.public[0]: Creating...
...
aws_db_instance.stt: Still creating... [10m0s elapsed]
aws_db_instance.chat: Still creating... [10m0s elapsed]
...
Apply complete! Resources: 87 added, 0 changed, 0 destroyed.
```

### Step 5.5: Save Terraform Outputs

```powershell
# Save all outputs
terraform output > ..\..\..\terraform-outputs.txt

# View specific outputs
terraform output alb_dns_name
terraform output kafka_broker_ips
terraform output ecr_repositories
terraform output rds_endpoints
terraform output s3_buckets
```

**Save Important Information:**
```powershell
# Get ALB DNS name (you'll need this!)
$ALB_DNS = terraform output -raw alb_dns_name
Write-Host "ALB DNS: $ALB_DNS"

# Get Kafka IPs
$KAFKA_IPS = terraform output -json kafka_broker_ips | ConvertFrom-Json
Write-Host "Kafka Brokers: $KAFKA_IPS"

# Get RDS endpoints
terraform output -json rds_endpoints
```

---

## 6. Configure Kafka Cluster

### Step 6.1: Get EC2 Instance Information

```powershell
# Back to project root
cd ..\..\..

# Get Kafka broker IPs
cd infrastructure\environments\dev
$KAFKA_IPS = terraform output -json kafka_broker_ips | ConvertFrom-Json
$ZOOKEEPER_IPS = terraform output -json zookeeper_ips | ConvertFrom-Json

Write-Host "Kafka Brokers:"
$KAFKA_IPS | ForEach-Object { Write-Host "  $_" }

Write-Host "Zookeeper Nodes:"
$ZOOKEEPER_IPS | ForEach-Object { Write-Host "  $_" }
```

### Step 6.2: Configure Kafka Topics

**Option A: Automated Script** (Create this script)

Create `scripts\setup-kafka.ps1`:
```powershell
# Get Kafka broker IP
$KAFKA_IP = (terraform output -json kafka_broker_ips | ConvertFrom-Json)[0]

# SSH to Kafka broker (you'll need the PEM key)
ssh -i your-key.pem ec2-user@$KAFKA_IP

# Once inside the broker, create topics:
/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 2 \
  --partitions 3 \
  --topic document.uploaded

/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 2 \
  --partitions 3 \
  --topic document.processed

/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 2 \
  --partitions 3 \
  --topic notes.generated

/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 2 \
  --partitions 3 \
  --topic quiz.requested

/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 2 \
  --partitions 3 \
  --topic quiz.generated

/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 2 \
  --partitions 3 \
  --topic audio.transcription.requested

/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 2 \
  --partitions 3 \
  --topic audio.transcription.completed

/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 2 \
  --partitions 3 \
  --topic audio.generation.requested

/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 2 \
  --partitions 3 \
  --topic audio.generation.completed

/opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 2 \
  --partitions 3 \
  --topic chat.message

# List topics to verify
/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092

# Exit SSH
exit
```

### Step 6.3: Verify Kafka Cluster

```bash
# On Kafka broker (via SSH)
# Check cluster status
/opt/kafka/bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092

# Check topic list
/opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092

# Describe a topic
/opt/kafka/bin/kafka-topics.sh --describe --topic document.uploaded --bootstrap-server localhost:9092
```

---

## 7. Setup RDS Databases

### Step 7.1: Get RDS Endpoints

```powershell
cd infrastructure\environments\dev

# Get all RDS endpoints
terraform output -json rds_endpoints

# Save to variable
$RDS_ENDPOINTS = terraform output -json rds_endpoints | ConvertFrom-Json
```

### Step 7.2: Connect to Database (Verify)

**Install PostgreSQL Client (optional for testing):**
```powershell
choco install postgresql -y
```

**Test Connection:**
```powershell
# Get STT DB endpoint
$STT_DB = $RDS_ENDPOINTS.stt -replace ":5432", ""

# Connect to database
psql -h $STT_DB -U dbadmin -d stt_service_db

# Enter password when prompted
# If successful, you'll see:
# stt_service_db=>
```

### Step 7.3: Initialize Database Schemas

The services will automatically create tables on first run, but you can pre-create them:

**Create `scripts\init-rds.ps1`:**
```powershell
$ENDPOINTS = terraform output -json rds_endpoints | ConvertFrom-Json
$DB_PASSWORD = $env:DB_PASSWORD

# For each service, create schema
# This is done automatically by services, but you can verify connectivity
```

---

## 8. Build and Push Docker Images

### Step 8.1: Login to Amazon ECR

```powershell
# Back to project root
cd C:\cloud-computing-project-full-implementation

# Get AWS account ID
$AWS_ACCOUNT_ID = (aws sts get-caller-identity --query Account --output text)
$AWS_REGION = "us-east-1"
$ECR_REGISTRY = "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

Write-Host "ECR Registry: $ECR_REGISTRY"

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Should see: Login Succeeded
```

### Step 8.2: Build Docker Images

**Make sure Docker Desktop is running!**

```powershell
# Build all images using script
.\scripts\build-and-push.ps1

# This will:
# 1. Create ECR repositories if they don't exist
# 2. Build Docker images for all services
# 3. Tag images with timestamp and 'latest'
# 4. Push to ECR
```

**What Happens:**
```
Building tts-service...
[+] Building 45.2s
Successfully built abc123def456
Tagging: learning-platform/tts-service:latest
Pushing: learning-platform/tts-service:latest
...
✓ Successfully pushed all images
```

**Manual Build (if script fails):**
```powershell
# Build TTS Service manually
cd services\tts-service
docker build -t tts-service:latest .

# Tag for ECR
docker tag tts-service:latest ${ECR_REGISTRY}/learning-platform/tts-service:latest

# Push to ECR
docker push ${ECR_REGISTRY}/learning-platform/tts-service:latest

# Repeat for other services
cd ..\..
```

### Step 8.3: Verify Images in ECR

```powershell
# List repositories
aws ecr describe-repositories --region $AWS_REGION

# List images in TTS repository
aws ecr list-images --repository-name learning-platform/tts-service --region $AWS_REGION
```

---

## 9. Deploy Microservices

### Step 9.1: Choose Deployment Method

**Option A: Kubernetes (Recommended)**
**Option B: Docker Swarm (Simpler)**

### Step 9.2: Deploy with Kubernetes

**Install kubectl:**
```powershell
choco install kubernetes-cli -y
```

**Configure kubectl:**
```powershell
# If using EKS (Elastic Kubernetes Service)
aws eks update-kubeconfig --region us-east-1 --name learning-platform-cluster

# Verify
kubectl get nodes
```

**Deploy Services:**
```powershell
# Deploy using script
.\scripts\deploy-services.ps1 -Environment dev

# This will:
# 1. Create namespace
# 2. Create secrets
# 3. Deploy all services
# 4. Create HPA (Horizontal Pod Autoscaler)
```

**Manual Deployment:**
```powershell
# Create namespace
kubectl apply -f kubernetes\base\namespace.yaml

# Create secrets
$JWT_SECRET = $env:JWT_SECRET
$OPENAI_KEY = $env:OPENAI_API_KEY

kubectl create secret generic app-secrets `
  --from-literal=jwt-secret=$JWT_SECRET `
  --from-literal=openai-api-key=$OPENAI_KEY `
  --namespace=learning-platform

# Update image references in manifests
# (Replace ${ECR_REGISTRY} with actual value)
Get-ChildItem kubernetes\base\*.yaml | ForEach-Object {
    (Get-Content $_.FullName) -replace '\$\{ECR_REGISTRY\}', $ECR_REGISTRY | Set-Content $_.FullName
}

# Deploy all services
kubectl apply -f kubernetes\base\

# Wait for deployments
kubectl wait --for=condition=available --timeout=300s deployment --all -n learning-platform
```

**Check Deployment Status:**
```powershell
# Get pods
kubectl get pods -n learning-platform

# Get services
kubectl get services -n learning-platform

# Get deployments
kubectl get deployments -n learning-platform

# View logs
kubectl logs -f deployment/tts-service -n learning-platform
```

### Step 9.3: Deploy with Docker Swarm (Alternative)

```powershell
# Initialize swarm on manager node (EC2)
# SSH to container host
ssh -i your-key.pem ec2-user@<container-host-ip>

# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.yml learning-platform

# Check services
docker service ls

# View logs
docker service logs learning-platform_tts-service
```

---

## 10. Verify Deployment

### Step 10.1: Get Load Balancer URL

```powershell
cd infrastructure\environments\dev

# Get ALB DNS name
$ALB_DNS = terraform output -raw alb_dns_name
Write-Host "Application URL: http://$ALB_DNS"
```

### Step 10.2: Health Checks

```powershell
# Check API Gateway health
Invoke-RestMethod -Uri "http://$ALB_DNS/health"

# Check all services
Invoke-RestMethod -Uri "http://$ALB_DNS/services/health"

# Or use script
cd ..\..\..
.\scripts\health-check.ps1 -AlbDns $ALB_DNS
```

### Step 10.3: Test Services

**Test TTS Service:**
```powershell
$body = @{
    text = "Hello from AWS deployment"
    language = "en"
    user_id = "test-user"
    format = "mp3"
} | ConvertTo-Json

$response = Invoke-RestMethod `
    -Uri "http://$ALB_DNS/api/tts/synthesize" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body

# Should return audio_id and download_url
Write-Host "Audio ID: $($response.audio_id)"
Write-Host "Download URL: $($response.download_url)"
```

**Test in Browser:**
1. Open browser
2. Go to: `http://YOUR-ALB-DNS/health`
3. Should see: `{"status":"healthy"}`

### Step 10.4: Verify AWS Resources

```powershell
# Check EC2 instances
aws ec2 describe-instances --region us-east-1 --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress]' --output table

# Check RDS instances
aws rds describe-db-instances --region us-east-1 --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address]' --output table

# Check S3 buckets
aws s3 ls | findstr learning-platform

# Check load balancers
aws elbv2 describe-load-balancers --region us-east-1 --query 'LoadBalancers[*].[LoadBalancerName,DNSName,State.Code]' --output table
```

---

## 11. Configure DNS (Optional)

### Step 11.1: Register Domain

1. Go to Route 53 or your domain registrar
2. Register domain (e.g., `learning-platform.com`)

### Step 11.2: Create Route 53 Hosted Zone

```powershell
# Create hosted zone
aws route53 create-hosted-zone `
    --name learning-platform.com `
    --caller-reference $(Get-Date -Format "yyyyMMddHHmmss")
```

### Step 11.3: Point Domain to ALB

```powershell
# Get ALB DNS
$ALB_DNS = terraform output -raw alb_dns_name

# Create Route 53 record
# (Use AWS Console for easier setup)
```

In AWS Console:
1. Route 53 → Hosted Zones → Your domain
2. Create Record
3. Record name: `api` (for api.learning-platform.com)
4. Record type: `A - IPv4 address`
5. Alias: Yes
6. Route traffic to: `Alias to Application Load Balancer`
7. Region: `us-east-1`
8. Choose your ALB
9. Create records

Now access: `http://api.learning-platform.com/health`

---

## 12. Monitoring & Logging

### Step 12.1: CloudWatch Dashboard

**Create Dashboard:**
```powershell
# Create CloudWatch dashboard
aws cloudwatch put-dashboard `
    --dashboard-name learning-platform-dev `
    --dashboard-body file://cloudwatch-dashboard.json
```

**Access Dashboard:**
1. AWS Console → CloudWatch → Dashboards
2. Click `learning-platform-dev`

### Step 12.2: View Logs

**CloudWatch Logs:**
```powershell
# List log groups
aws logs describe-log-groups --region us-east-1

# Tail logs for TTS service
aws logs tail /aws/ecs/tts-service --follow --region us-east-1
```

**Kubernetes Logs:**
```powershell
# View pod logs
kubectl logs -f deployment/tts-service -n learning-platform

# View all pod logs
kubectl logs -f -l app=tts-service -n learning-platform
```

### Step 12.3: Set Up Alarms

```powershell
# Create CPU alarm
aws cloudwatch put-metric-alarm `
    --alarm-name high-cpu-tts-service `
    --alarm-description "TTS service high CPU" `
    --metric-name CPUUtilization `
    --namespace AWS/EC2 `
    --statistic Average `
    --period 300 `
    --threshold 80 `
    --comparison-operator GreaterThanThreshold `
    --evaluation-periods 2
```

---

## 13. Cost Management

### Step 13.1: Check Current Costs

```powershell
# Get cost and usage
aws ce get-cost-and-usage `
    --time-period Start=2024-01-01,End=2024-01-31 `
    --granularity MONTHLY `
    --metrics BlendedCost `
    --region us-east-1
```

### Step 13.2: Estimated Monthly Costs (Dev Environment)

**Cost Breakdown:**
```
EC2 Instances:
- 3 Kafka brokers (t3.large): ~$150/month
- 3 Zookeeper nodes (t3.medium): ~$90/month
- 3 Container hosts (t3.medium): ~$90/month

RDS Instances:
- 5 PostgreSQL db.t3.medium: ~$300/month

Load Balancers:
- 1 ALB: ~$23/month
- 1 NLB: ~$23/month

Data Transfer:
- ~$20/month

S3 Storage:
- ~$5/month (minimal data)

TOTAL: ~$700/month for full dev environment
```

### Step 13.3: Cost Optimization Tips

**For Development:**
```powershell
# Use smaller instances
# Edit terraform.tfvars:
# instance_type = "t3.small"
# kafka_instance_type = "t3.medium"
# db_instance_class = "db.t3.small"
```

**Stop Non-Essential Resources:**
```powershell
# Stop RDS instances when not in use
aws rds stop-db-instance --db-instance-identifier learning-platform-stt-db-dev

# Stop EC2 instances
aws ec2 stop-instances --instance-ids i-1234567890abcdef0
```

**Use Spot Instances:**
Edit Terraform to use spot instances for cost savings.

---

## 14. Troubleshooting

### Issue: Terraform Apply Fails

**Error: VPC Limit Exceeded**
```
Solution:
1. Delete unused VPCs
2. Request limit increase via AWS Support
```

**Error: RDS Creation Timeout**
```
Solution:
- RDS takes 15-20 minutes
- Wait longer
- Check subnet group configuration
```

### Issue: Cannot Connect to RDS

**Check Security Group:**
```powershell
# Get RDS security group
$SG_ID = (terraform output -raw rds_security_group_id)

# Check rules
aws ec2 describe-security-groups --group-ids $SG_ID
```

**Solution:**
```powershell
# Add your IP if connecting from local
aws ec2 authorize-security-group-ingress `
    --group-id $SG_ID `
    --protocol tcp `
    --port 5432 `
    --cidr YOUR-IP/32
```

### Issue: Services Not Accessible

**Check Load Balancer:**
```powershell
# Get ALB status
aws elbv2 describe-load-balancers
```

**Check Target Groups:**
```powershell
# Get target health
aws elbv2 describe-target-health --target-group-arn YOUR-TG-ARN
```

### Issue: Docker Build Fails

**Check Docker Desktop:**
- Make sure Docker Desktop is running
- Check available disk space
- Try: `docker system prune -a`

### Issue: High AWS Costs

**Review Resources:**
```powershell
# List all EC2 instances
aws ec2 describe-instances

# List all RDS instances
aws rds describe-db-instances

# Check for unused resources
```

---

## 15. Tear Down (When Done)

### Step 15.1: Save Important Data

**Backup RDS Databases:**
```powershell
# Create manual snapshot
aws rds create-db-snapshot `
    --db-instance-identifier learning-platform-stt-db-dev `
    --db-snapshot-identifier stt-db-final-backup-20240101
```

**Backup S3 Data:**
```powershell
# Sync S3 to local
aws s3 sync s3://learning-platform-tts-service-storage-dev C:\backups\tts-data
```

### Step 15.2: Destroy Infrastructure

```powershell
cd infrastructure\environments\dev

# Destroy everything
terraform destroy

# Review what will be deleted
# Type 'yes' when prompted

# This will DELETE:
# ❌ All EC2 instances
# ❌ All RDS databases
# ❌ All S3 buckets (empty them first!)
# ❌ Load balancers
# ❌ VPC and networking
```

**Empty S3 Buckets First:**
```powershell
# List buckets
aws s3 ls | findstr learning-platform

# Empty each bucket
aws s3 rm s3://learning-platform-tts-service-storage-dev --recursive
aws s3 rm s3://learning-platform-stt-service-storage-dev --recursive
# ... repeat for all buckets

# Now run terraform destroy
terraform destroy
```

### Step 15.3: Verify Cleanup

```powershell
# Check no EC2 instances remain
aws ec2 describe-instances --region us-east-1 --query 'Reservations[*].Instances[*].[InstanceId,State.Name]'

# Check no RDS instances remain
aws rds describe-db-instances --region us-east-1

# Check no load balancers remain
aws elbv2 describe-load-balancers --region us-east-1
```

---

## 📋 Complete Deployment Checklist

- [ ] AWS account created
- [ ] AWS CLI installed and configured
- [ ] Terraform installed
- [ ] Project cloned
- [ ] .env file configured
- [ ] terraform.tfvars configured
- [ ] Terraform initialized
- [ ] Infrastructure deployed (terraform apply)
- [ ] Outputs saved
- [ ] Kafka topics created
- [ ] Docker images built
- [ ] Images pushed to ECR
- [ ] Services deployed to Kubernetes/Swarm
- [ ] Health checks passing
- [ ] Services accessible via ALB
- [ ] Monitoring configured
- [ ] Cost alerts set

---

## 🎯 Quick Reference Commands

```powershell
# AWS
aws configure
aws sts get-caller-identity
aws s3 ls
aws ec2 describe-instances

# Terraform
cd infrastructure\environments\dev
terraform init
terraform plan
terraform apply
terraform output
terraform destroy

# Docker
docker login
.\scripts\build-and-push.ps1

# Kubernetes
kubectl get pods -n learning-platform
kubectl get services -n learning-platform
kubectl logs -f deployment/tts-service -n learning-platform

# Health Check
.\scripts\health-check.ps1 -AlbDns YOUR-ALB-DNS
```

---

## 📞 Support

**AWS Support:**
- Console: https://console.aws.amazon.com/support
- Documentation: https://docs.aws.amazon.com
- Forums: https://forums.aws.amazon.com

**Project Issues:**
- Check logs: `kubectl logs` or CloudWatch
- Review [Troubleshooting Guide](TROUBLESHOOTING.md)
- GitHub Issues

---

**🎉 Congratulations! Your Cloud Learning Platform is now running on AWS!**

Access your platform: `http://YOUR-ALB-DNS`

Remember to monitor costs and stop resources when not in use!
