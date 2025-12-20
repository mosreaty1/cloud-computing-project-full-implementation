# Terraform Deployment Troubleshooting

## Quick Fix Commands (PowerShell)

### Run the automated fix script:
```powershell
.\fix-state.ps1
```

---

## Manual Fixes

### Issue 1: IAM Instance Profile Already Exists

**Error:**
```
Error: creating IAM Instance Profile (learning-platform-ec2-container-host-dev): EntityAlreadyExists
```

**Fix:**
```powershell
terraform import module.iam.aws_iam_instance_profile.ec2_container_host learning-platform-ec2-container-host-dev
```

---

### Issue 2: RDS Subnet Group VPC Mismatch

**Error:**
```
Error: The new Subnets are not in the same Vpc as the existing subnet group
```

**Cause:** Old DB subnet group references a deleted VPC

**Fix:**
```powershell
# Delete the old subnet group
aws rds delete-db-subnet-group --db-subnet-group-name learning-platform-db-subnet-group-dev

# Then run terraform apply again (it will create a new one)
terraform apply
```

---

### Issue 3: Elastic IP Limit Exceeded

**Error:**
```
Error: The maximum number of addresses has been reached
```

**Cause:** AWS Free Tier allows max 5 Elastic IPs per region

**Fix:**

1. **Check current EIPs:**
   ```powershell
   aws ec2 describe-addresses
   ```

2. **Release unused EIPs via AWS Console:**
   - Go to: https://console.aws.amazon.com/ec2/
   - Click "Elastic IPs" in the left menu
   - Select unassociated IPs (where "Associated instance ID" is empty)
   - Actions → Release Elastic IP addresses

3. **Or release via CLI:**
   ```powershell
   # Get allocation ID from the describe-addresses command above
   aws ec2 release-address --allocation-id eipalloc-xxxxxxxxxxxxx
   ```

---

### Issue 4: Resources Already Exist (General)

**Common errors:**
- ECR Repository already exists
- S3 Bucket already exists
- IAM Role already exists

**Fix - Import them:**

```powershell
# ECR Repositories
terraform import module.ecr.aws_ecr_repository.tts learning-platform/tts-service
terraform import module.ecr.aws_ecr_repository.stt learning-platform/stt-service
terraform import module.ecr.aws_ecr_repository.chat learning-platform/chat-service
terraform import module.ecr.aws_ecr_repository.document learning-platform/document-reader-service
terraform import module.ecr.aws_ecr_repository.quiz learning-platform/quiz-service
terraform import module.ecr.aws_ecr_repository.api_gateway learning-platform/api-gateway

# S3 Buckets
terraform import module.s3.aws_s3_bucket.tts learning-platform-tts-service-storage-dev
terraform import module.s3.aws_s3_bucket.stt learning-platform-stt-service-storage-dev
terraform import module.s3.aws_s3_bucket.chat learning-platform-chat-service-storage-dev
terraform import module.s3.aws_s3_bucket.document learning-platform-document-reader-storage-dev
terraform import module.s3.aws_s3_bucket.quiz learning-platform-quiz-service-storage-dev
terraform import module.s3.aws_s3_bucket.shared learning-platform-shared-assets-dev

# IAM Roles
terraform import module.iam.aws_iam_role.ec2_container_host learning-platform-ec2-container-host-dev
terraform import module.iam.aws_iam_role.tts_service learning-platform-tts-service-dev
terraform import module.iam.aws_iam_role.stt_service learning-platform-stt-service-dev
terraform import module.iam.aws_iam_role.chat_service learning-platform-chat-service-dev
terraform import module.iam.aws_iam_role.document_service learning-platform-document-service-dev
terraform import module.iam.aws_iam_role.quiz_service learning-platform-quiz-service-dev
terraform import module.iam.aws_iam_role.lambda_execution learning-platform-lambda-execution-dev

# VPC Flow Logs
terraform import module.vpc.aws_cloudwatch_log_group.vpc_flow_logs /aws/vpc/learning-platform-dev
terraform import module.vpc.aws_iam_role.vpc_flow_logs learning-platform-vpc-flow-logs-role-dev
```

---

## Nuclear Option: Start Fresh

If nothing else works, you can delete all resources and start over:

### ⚠️ WARNING: This will delete everything!

```powershell
# 1. Delete all resources via Terraform
terraform destroy -auto-approve

# 2. Clean up any orphaned resources manually in AWS Console

# 3. Remove state files
Remove-Item .terraform -Recurse -Force
Remove-Item terraform.tfstate* -Force

# 4. Start fresh
terraform init
terraform plan
terraform apply
```

---

## Common Issues

### Load Balancers Not Supported

**Error:**
```
Error: This AWS account currently does not support creating load balancers
```

**Status:** ✓ Already fixed - load balancers are disabled by default

**To enable later:**
1. Contact AWS Support
2. Set `enable_load_balancers = true` in `main.tf`

---

### Need Help?

1. Check logs: Look at the full error message
2. AWS Console: Verify resource states manually
3. Terraform state: Run `terraform show` to see current state
4. Clean rebuild: Use the nuclear option above

---

## Quick Verification Commands

```powershell
# Check Terraform state
terraform state list

# Verify AWS resources exist
aws ecr describe-repositories
aws s3 ls
aws iam list-roles --query 'Roles[?contains(RoleName, `learning-platform`)].RoleName'
aws ec2 describe-addresses

# Validate configuration
terraform validate

# Preview changes
terraform plan
```
