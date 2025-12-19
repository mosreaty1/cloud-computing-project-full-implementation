# Deployment Guide

Complete guide for deploying the Cloud-Based Learning Platform.

## Table of Contents

1. [Local Development](#local-development)
2. [AWS Deployment](#aws-deployment)
3. [CI/CD Pipeline](#cicd-pipeline)
4. [Rolling Updates](#rolling-updates)
5. [Rollback Procedures](#rollback-procedures)

## Local Development

### Quick Start

```bash
# 1. Setup local environment
./scripts/setup-local.sh

# 2. Configure environment variables
cp .env.example .env
nano .env  # Add your API keys

# 3. Start all services
docker-compose up -d

# 4. Check health
./scripts/health-check.sh

# 5. View logs
docker-compose logs -f api-gateway
```

### Individual Service Development

```bash
# Start only specific services
docker-compose up -d postgres kafka zookeeper localstack

# Run service locally
cd services/tts-service
pip install -r requirements.txt
uvicorn src.main:app --reload --port 8001

# Test the service
curl http://localhost:8001/health
```

## AWS Deployment

### Prerequisites

```bash
# Verify AWS credentials
aws sts get-caller-identity

# Verify Terraform state
cd infrastructure/environments/dev
terraform state list
```

### Build and Push Docker Images

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Build all services
./scripts/build-and-push.sh

# Or build individually
cd services/tts-service
docker build -t learning-platform/tts-service:v1.0.0 .
docker tag learning-platform/tts-service:v1.0.0 \
  $ECR_REGISTRY/learning-platform/tts-service:v1.0.0
docker push $ECR_REGISTRY/learning-platform/tts-service:v1.0.0
```

### Deploy Using Kubernetes

```bash
# Apply Kubernetes manifests
kubectl apply -f kubernetes/base/

# Check deployment status
kubectl get deployments -n learning-platform
kubectl get pods -n learning-platform
kubectl get services -n learning-platform

# Check logs
kubectl logs -f deployment/tts-service -n learning-platform
```

### Deploy Using Docker Swarm

```bash
# Initialize swarm (on manager node)
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.prod.yml learning-platform

# Check services
docker service ls
docker service logs learning-platform_tts-service
```

## CI/CD Pipeline

### GitHub Actions Setup

1. **Configure Secrets:**

```bash
# In GitHub Repository Settings → Secrets:
AWS_ACCOUNT_ID: <your-account-id>
AWS_ACCESS_KEY_ID: <access-key>
AWS_SECRET_ACCESS_KEY: <secret-key>
OPENAI_API_KEY: <openai-key>
```

2. **Workflow Triggers:**

- Push to `main` → Deploy to production
- Push to `develop` → Deploy to development
- Pull requests → Run tests only

3. **Pipeline Stages:**

```
┌─────────┐
│  Test   │
└────┬────┘
     │
┌────▼────┐
│  Build  │
└────┬────┘
     │
┌────▼────┐
│  Push   │
└────┬────┘
     │
┌────▼────┐
│ Deploy  │
└─────────┘
```

## Rolling Updates

### Zero-Downtime Deployment

```bash
# Update service with new image
kubectl set image deployment/tts-service \
  tts-service=$ECR_REGISTRY/learning-platform/tts-service:v1.1.0 \
  -n learning-platform

# Monitor rollout
kubectl rollout status deployment/tts-service -n learning-platform

# Verify new pods
kubectl get pods -n learning-platform -w
```

### Blue-Green Deployment

```bash
# Deploy green environment
kubectl apply -f kubernetes/overlays/green/

# Test green environment
curl http://green-alb-dns/health

# Switch traffic to green
kubectl patch service api-gateway \
  -p '{"spec":{"selector":{"version":"green"}}}'

# Remove blue environment
kubectl delete -f kubernetes/overlays/blue/
```

## Rollback Procedures

### Kubernetes Rollback

```bash
# View rollout history
kubectl rollout history deployment/tts-service -n learning-platform

# Rollback to previous version
kubectl rollout undo deployment/tts-service -n learning-platform

# Rollback to specific revision
kubectl rollout undo deployment/tts-service \
  --to-revision=2 -n learning-platform
```

### Docker Swarm Rollback

```bash
# Update service to previous image
docker service update \
  --image $ECR_REGISTRY/learning-platform/tts-service:v1.0.0 \
  learning-platform_tts-service

# Rollback service
docker service rollback learning-platform_tts-service
```

### Database Rollback

```bash
# Restore from RDS snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier learning-platform-stt-db-restored \
  --db-snapshot-identifier learning-platform-stt-db-snapshot-date

# Point application to restored database
kubectl set env deployment/stt-service \
  DATABASE_URL=postgresql://user:pass@restored-db:5432/stt_service_db
```

## Monitoring Deployment

### Health Checks

```bash
# Check all services
./scripts/health-check.sh

# Check specific service
curl http://alb-dns/api/tts/health

# Check metrics
curl http://alb-dns/api/tts/metrics
```

### View Logs

```bash
# Kubernetes
kubectl logs -f deployment/tts-service -n learning-platform

# CloudWatch Logs
aws logs tail /aws/ecs/tts-service --follow

# Local
docker-compose logs -f tts-service
```

## Troubleshooting Deployment

### Issue: Image Pull Errors

```bash
# Verify ECR authentication
aws ecr get-login-password --region us-east-1

# Check image exists
aws ecr describe-images \
  --repository-name learning-platform/tts-service

# Update ImagePullSecrets
kubectl create secret docker-registry ecr-secret \
  --docker-server=$ECR_REGISTRY \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password)
```

### Issue: Service Not Starting

```bash
# Check events
kubectl describe pod <pod-name> -n learning-platform

# Check logs
kubectl logs <pod-name> -n learning-platform

# Check resources
kubectl top pods -n learning-platform
```

### Issue: Database Connection Failures

```bash
# Verify RDS endpoint
aws rds describe-db-instances \
  --db-instance-identifier learning-platform-stt-db-dev

# Test connection
psql -h <rds-endpoint> -U dbadmin -d stt_service_db

# Check security groups
aws ec2 describe-security-groups --group-ids <sg-id>
```

## Best Practices

1. **Always test in development first**
2. **Use versioned Docker images (avoid :latest)**
3. **Monitor deployment progress**
4. **Keep rollback plan ready**
5. **Document any manual changes**
6. **Review logs after deployment**
7. **Run smoke tests post-deployment**

## Next Steps

- [Monitoring Guide](MONITORING-GUIDE.md)
- [Security Guide](SECURITY-GUIDE.md)
- [Troubleshooting](TROUBLESHOOTING.md)
