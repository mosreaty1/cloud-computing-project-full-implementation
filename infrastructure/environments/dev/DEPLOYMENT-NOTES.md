# Deployment Notes for AWS Free Tier

## ⚠️ Load Balancer Limitation

Your AWS account currently **does not support creating load balancers**. This is a common limitation for new AWS accounts or Free Tier accounts. You'll see this error:

```
Error: This AWS account currently does not support creating load balancers.
For more information, please contact AWS Support.
```

### Solution Applied

The infrastructure has been modified to work **without load balancers** by default:

1. **Load balancers are now optional** - controlled by the `enable_load_balancers` variable
2. **Currently disabled** - `enable_load_balancers = false` in `main.tf`
3. **Services will still work** - EC2 instances can be accessed directly via their public IPs

### Enabling Load Balancers Later

If you need load balancers:

1. **Contact AWS Support** to request load balancer access for your account
2. After approval, edit `infrastructure/environments/dev/main.tf`:
   ```hcl
   module "elb" {
     # ... other settings ...
     enable_load_balancers = true  # Change from false to true
   }
   ```
3. Run `terraform apply` to create the load balancers

## Fixing "Resource Already Exists" Errors

If you see errors like:
- `ECR Repository already exists`
- `S3 Bucket already exists`
- `IAM Role already exists`

These occur because resources were created in a previous deployment but aren't in your current Terraform state.

### Quick Fix

Run the import script to add existing resources to Terraform state:

```bash
cd infrastructure/environments/dev
chmod +x fix-state.sh
./fix-state.sh
```

This script will automatically import all existing AWS resources into your Terraform state.

### Manual Cleanup (Alternative)

If you prefer to start fresh:

```bash
# Delete existing resources manually in AWS Console, then:
cd infrastructure/environments/dev
rm -rf .terraform terraform.tfstate*
terraform init
terraform plan
terraform apply
```

## Deployment Steps

1. **Fix the state** (if resources already exist):
   ```bash
   cd infrastructure/environments/dev
   ./fix-state.sh
   ```

2. **Verify the plan**:
   ```bash
   terraform plan
   ```

3. **Apply the infrastructure**:
   ```bash
   terraform apply
   ```

## Architecture Without Load Balancers

When load balancers are disabled:

- **API Gateway**: Accessible via EC2 instance public IP on port 8000
- **Kafka**: Accessible within VPC via private IPs on port 9092
- **Services**: Deploy normally to EC2 instances
- **Security Groups**: Still control access to instances

This is suitable for:
- Development environments
- Testing
- Learning AWS
- Free Tier usage

For production, you should enable load balancers for:
- High availability
- Auto-scaling
- SSL termination
- Health checks
- Traffic distribution

## Cost Optimization

Running without load balancers saves approximately:
- **ALB**: ~$16-20/month
- **NLB**: ~$16-20/month
- **Total**: ~$32-40/month savings

## Questions?

- Check AWS Free Tier limits: https://aws.amazon.com/free/
- Contact AWS Support for load balancer access
- Review infrastructure costs in AWS Cost Explorer
