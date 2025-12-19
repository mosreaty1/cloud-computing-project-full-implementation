# AWS Infrastructure Setup Guide

This comprehensive guide walks you through deploying the Cloud-Based Learning Platform infrastructure on AWS.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [AWS Account Setup](#aws-account-setup)
3. [Local Environment Setup](#local-environment-setup)
4. [Infrastructure Deployment](#infrastructure-deployment)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools

```bash
# AWS CLI v2+
aws --version

# Terraform v1.5+
terraform --version

# Docker v20+
docker --version

# kubectl v1.28+
kubectl version --client

# jq (for JSON processing)
jq --version
```

### Required Access

- AWS Account with administrative access
- Estimated budget: $200-500/month for dev environment
- Domain name (optional, for custom URLs)

## AWS Account Setup

### Step 1: Create AWS Account

1. Visit [AWS Console](https://aws.amazon.com)
2. Click "Create an AWS Account"
3. Complete registration process
4. Set up billing alerts (recommended)

### Step 2: Create IAM User for Terraform

```bash
# Login to AWS Console as root user
# Navigate to IAM → Users → Create User

# User details:
Username: terraform-deploy
Access type: Programmatic access

# Attach policies:
- AdministratorAccess (for initial setup)
# In production, use more restrictive policies

# Save the Access Key ID and Secret Access Key
```

### Step 3: Configure AWS CLI

```bash
# Configure AWS credentials
aws configure

# Enter when prompted:
AWS Access Key ID: <your-access-key>
AWS Secret Access Key: <your-secret-key>
Default region name: us-east-1
Default output format: json

# Verify configuration
aws sts get-caller-identity
```

## Local Environment Setup

### Step 1: Clone Repository

```bash
git clone <repository-url>
cd cloud-computing-project-full-implementation
```

### Step 2: Configure Environment Variables

```bash
# Copy environment template
cp .env.example .env

# Edit with your values
nano .env

# Required variables:
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=<your-account-id>
ENVIRONMENT=dev
DB_PASSWORD=<secure-password>
OPENAI_API_KEY=<your-openai-key>
JWT_SECRET=<secure-random-string>
```

### Step 3: Generate Secure Secrets

```bash
# Generate secure database password
openssl rand -base64 32

# Generate JWT secret
openssl rand -hex 32
```

## Infrastructure Deployment

### Step 1: Initialize Terraform

```bash
cd infrastructure/environments/dev

# Initialize Terraform
terraform init

# Validate configuration
terraform validate
```

### Step 2: Create terraform.tfvars

```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

Example `terraform.tfvars`:

```hcl
aws_region   = "us-east-1"
project_name = "learning-platform"
environment  = "dev"
vpc_cidr     = "10.0.0.0/16"

db_username = "dbadmin"
db_password = "your-secure-password-here"
```

### Step 3: Plan Deployment

```bash
# Review what will be created
terraform plan -out=tfplan

# Review the plan carefully:
# - Verify resource names
# - Check CIDR blocks
# - Confirm instance types
# - Review estimated costs
```

### Step 4: Apply Infrastructure

```bash
# Apply the plan
terraform apply tfplan

# This will create:
# - VPC with subnets across 2 AZs
# - 3 Kafka brokers
# - 3 Zookeeper nodes
# - Auto-scaling group for container hosts
# - 5 RDS PostgreSQL instances
# - 6 S3 buckets
# - Application Load Balancer
# - Network Load Balancer
# - Security groups
# - IAM roles and policies
# - ECR repositories

# Deployment time: ~20-30 minutes
```

### Step 5: Save Outputs

```bash
# Save important outputs
terraform output > ../../../terraform-outputs.json

# View specific outputs
terraform output alb_dns_name
terraform output kafka_broker_ips
terraform output ecr_repositories
```

## Post-Deployment Configuration

### Step 1: Configure Kafka Cluster

```bash
# SSH to Kafka brokers
KAFKA_IP=$(terraform output -json kafka_broker_ips | jq -r '.[0]')

# Update Zookeeper connection strings
# This is handled by EC2 user data, but verify:
ssh ec2-user@<kafka-broker-ip>
sudo vi /opt/kafka/config/server.properties
# Verify zookeeper.connect has all 3 Zookeeper IPs
```

### Step 2: Create Kafka Topics

```bash
# Create topics for event-driven architecture
./scripts/create-kafka-topics.sh

# Or manually:
KAFKA_IP=$(terraform output -json kafka_broker_ips | jq -r '.[0]')
ssh ec2-user@$KAFKA_IP

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

# Repeat for all topics (see docs/architecture/KAFKA-EVENTS.md)
```

### Step 3: Initialize Databases

```bash
# Run database migrations for each service
./scripts/init-databases.sh

# This creates tables for:
# - STT Service: transcriptions, metadata
# - Chat Service: conversations, messages
# - Document Reader: documents, notes
# - Quiz Service: quizzes, questions, responses
# - User Management: users, sessions
```

### Step 4: Build and Push Docker Images

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Build and push all services
./scripts/build-and-push.sh

# Or build individually:
cd services/tts-service
docker build -t learning-platform/tts-service:latest .
docker tag learning-platform/tts-service:latest \
  <ecr-url>/learning-platform/tts-service:latest
docker push <ecr-url>/learning-platform/tts-service:latest
```

### Step 5: Deploy Services to EC2

```bash
# Deploy using Docker Swarm or Kubernetes
./scripts/deploy-services.sh dev

# This will:
# - Pull images from ECR
# - Configure environment variables
# - Start all services
# - Configure health checks
```

## Verification

### Step 1: Check Service Health

```bash
# Get ALB DNS name
ALB_DNS=$(terraform output -raw alb_dns_name)

# Check API Gateway health
curl http://$ALB_DNS/health

# Check individual services
curl http://$ALB_DNS/api/tts/health
curl http://$ALB_DNS/api/stt/health
curl http://$ALB_DNS/api/chat/health
curl http://$ALB_DNS/api/documents/health
curl http://$ALB_DNS/api/quiz/health
```

### Step 2: Verify Kafka

```bash
# List topics
KAFKA_IP=$(terraform output -json kafka_broker_ips | jq -r '.[0]')
ssh ec2-user@$KAFKA_IP

/opt/kafka/bin/kafka-topics.sh --list \
  --bootstrap-server localhost:9092

# Check consumer groups
/opt/kafka/bin/kafka-consumer-groups.sh --list \
  --bootstrap-server localhost:9092
```

### Step 3: Verify S3 Buckets

```bash
# List buckets
aws s3 ls | grep learning-platform

# Check bucket policies
aws s3api get-bucket-policy \
  --bucket learning-platform-tts-service-storage-dev
```

### Step 4: Verify RDS Instances

```bash
# List RDS instances
aws rds describe-db-instances \
  --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Endpoint.Address]' \
  --output table
```

### Step 5: Test End-to-End

```bash
# Test TTS service
curl -X POST http://$ALB_DNS/api/tts/synthesize \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Hello, this is a test",
    "language": "en",
    "user_id": "test-user"
  }'

# Test Document Upload
curl -X POST http://$ALB_DNS/api/documents/upload \
  -F "file=@test.pdf" \
  -F "user_id=test-user"
```

## Troubleshooting

### Issue: Terraform Apply Fails

**Symptoms:**
```
Error creating VPC: VpcLimitExceeded
```

**Solution:**
```bash
# Check VPC limits
aws ec2 describe-account-attributes \
  --attribute-names max-vpcs

# Delete unused VPCs
aws ec2 delete-vpc --vpc-id <vpc-id>

# Or request limit increase via AWS Support
```

### Issue: Kafka Brokers Not Starting

**Symptoms:**
- Kafka service fails to start
- Zookeeper connection errors

**Solution:**
```bash
# Check Zookeeper status
ssh ec2-user@<zookeeper-ip>
sudo systemctl status zookeeper

# Check Kafka logs
ssh ec2-user@<kafka-ip>
sudo journalctl -u kafka -f

# Verify Zookeeper connection in server.properties
cat /opt/kafka/config/server.properties | grep zookeeper.connect

# Should show all 3 Zookeeper IPs
```

### Issue: Services Can't Connect to RDS

**Symptoms:**
- Connection timeout errors
- "could not connect to server" errors

**Solution:**
```bash
# Check security group rules
aws ec2 describe-security-groups \
  --group-ids <rds-sg-id>

# Verify container security group has access
# Update security group if needed:
aws ec2 authorize-security-group-ingress \
  --group-id <rds-sg-id> \
  --protocol tcp \
  --port 5432 \
  --source-group <container-sg-id>
```

### Issue: S3 Access Denied

**Symptoms:**
- 403 Forbidden errors
- Access Denied when uploading/downloading

**Solution:**
```bash
# Check IAM role attached to EC2 instances
aws ec2 describe-instances \
  --instance-ids <instance-id> \
  --query 'Reservations[0].Instances[0].IamInstanceProfile'

# Check IAM role policies
aws iam get-role-policy \
  --role-name <role-name> \
  --policy-name <policy-name>

# Verify bucket policy
aws s3api get-bucket-policy \
  --bucket <bucket-name>
```

### Issue: High AWS Costs

**Symptoms:**
- Unexpected AWS bill
- Cost alerts triggered

**Solution:**
```bash
# Check resource usage
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost

# Stop non-essential resources
terraform destroy -target=module.rds  # If not needed

# Use smaller instance types for dev:
# Edit terraform.tfvars:
# instance_type = "t3.micro"
# db_instance_class = "db.t3.micro"
```

## Cost Optimization

### Development Environment

```hcl
# Use spot instances for container hosts
spot_price = "0.05"

# Use smaller instance types
instance_type = "t3.small"
db_instance_class = "db.t3.small"

# Disable Multi-AZ for RDS
multi_az = false

# Use single NAT Gateway
enable_single_nat_gateway = true

# Reduce Kafka cluster size
kafka_broker_count = 1
zookeeper_node_count = 1
```

### Stop Services After Hours

```bash
# Stop EC2 instances
aws ec2 stop-instances --instance-ids $(terraform output -json ec2_instance_ids | jq -r '.[]')

# Stop RDS instances
aws rds stop-db-instance --db-instance-identifier <db-id>

# Start them again when needed
./scripts/start-environment.sh
```

## Next Steps

1. ✅ Infrastructure deployed
2. ✅ Services running
3. ✅ Health checks passing

Now proceed to:
- [Deployment Guide](DEPLOYMENT-GUIDE.md) - Deploy application updates
- [API Documentation](../api/API-REFERENCE.md) - API endpoints and usage
- [Monitoring Guide](MONITORING-GUIDE.md) - Set up monitoring and alerting

## Support

For issues:
1. Check [Troubleshooting Guide](TROUBLESHOOTING.md)
2. Review CloudWatch logs
3. Check service health endpoints
4. Consult [AWS Documentation](https://docs.aws.amazon.com)
