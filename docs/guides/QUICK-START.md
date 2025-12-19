# Quick Start Guide

Get the Cloud-Based Learning Platform running in under 10 minutes!

## For Local Development (Fastest)

### Step 1: Prerequisites

```bash
# Install required tools
- Docker Desktop: https://www.docker.com/products/docker-desktop
- Git: https://git-scm.com/downloads

# Verify installations
docker --version
docker-compose --version
git --version
```

### Step 2: Clone and Setup

```bash
# Clone repository
git clone <repository-url>
cd cloud-computing-project-full-implementation

# Run setup script
chmod +x scripts/setup-local.sh
./scripts/setup-local.sh
```

### Step 3: Configure Environment

```bash
# Create .env file
cp .env.example .env

# Edit .env and add your OpenAI API key (optional but recommended)
nano .env
# Add: OPENAI_API_KEY=sk-your-key-here
```

### Step 4: Start Services

```bash
# Start all services
docker-compose up -d

# Wait ~2 minutes for services to initialize

# Check health
chmod +x scripts/health-check.sh
./scripts/health-check.sh
```

### Step 5: Test the Platform

```bash
# Test TTS (Text-to-Speech)
curl -X POST http://localhost:8000/api/tts/synthesize \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Hello World",
    "language": "en",
    "user_id": "test-user"
  }'

# You should get a JSON response with download_url
```

### Step 6: Access Services

- **API Gateway**: http://localhost:8000
- **TTS Service**: http://localhost:8001
- **STT Service**: http://localhost:8002
- **Chat Service**: http://localhost:8003
- **Document Reader**: http://localhost:8004
- **Quiz Service**: http://localhost:8005

### Step 7: View Logs

```bash
# View all logs
docker-compose logs -f

# View specific service
docker-compose logs -f tts-service

# View API Gateway logs
docker-compose logs -f api-gateway
```

## For AWS Deployment

### Prerequisites

- AWS Account with admin access
- AWS CLI configured
- Terraform installed
- Budget: ~$200-500/month

### Quick Deploy

```bash
# 1. Configure AWS
aws configure

# 2. Navigate to Terraform
cd infrastructure/environments/dev

# 3. Create terraform.tfvars
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Add your values

# 4. Initialize and apply
terraform init
terraform plan
terraform apply

# Deployment takes ~20-30 minutes
```

## Troubleshooting

### Services Won't Start

```bash
# Check Docker is running
docker ps

# Restart services
docker-compose down
docker-compose up -d

# Check logs for errors
docker-compose logs
```

### Connection Refused Errors

```bash
# Wait for services to fully start
sleep 60

# Check service status
docker-compose ps

# Restart specific service
docker-compose restart tts-service
```

### Port Already in Use

```bash
# Find process using port
lsof -i :8000

# Kill process or change port in docker-compose.yml
```

## Next Steps

### Local Development
1. ✅ Services running locally
2. 📖 Read [API Documentation](../api/API-REFERENCE.md)
3. 🔧 Start developing features
4. 📝 Review [Architecture](../architecture/MICROSERVICES.md)

### AWS Deployment
1. ✅ Infrastructure deployed
2. 📖 Read [AWS Setup Guide](AWS-SETUP-GUIDE.md)
3. 🚀 Deploy services
4. 📊 Setup [Monitoring](MONITORING-GUIDE.md)

## Common Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Restart a service
docker-compose restart <service-name>

# Rebuild a service
docker-compose up -d --build <service-name>

# Check health
./scripts/health-check.sh

# Run tests
pytest services/tts-service/tests/
```

## API Examples

### Text-to-Speech

```bash
curl -X POST http://localhost:8000/api/tts/synthesize \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Welcome to our learning platform",
    "language": "en",
    "format": "mp3",
    "user_id": "user123"
  }'
```

### Upload Document

```bash
curl -X POST http://localhost:8000/api/documents/upload \
  -F "file=@document.pdf" \
  -F "user_id=user123"
```

### Chat

```bash
curl -X POST http://localhost:8000/api/chat/message \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Explain quantum physics",
    "user_id": "user123",
    "conversation_id": "conv123"
  }'
```

## Getting Help

- 📖 [Full Documentation](../README.md)
- 🐛 [Troubleshooting Guide](TROUBLESHOOTING.md)
- 🔧 [Deployment Guide](DEPLOYMENT-GUIDE.md)
- 🏗️ [AWS Setup](AWS-SETUP-GUIDE.md)

## Support

For issues:
1. Check logs: `docker-compose logs`
2. Review [Troubleshooting Guide](TROUBLESHOOTING.md)
3. Check service health: `./scripts/health-check.sh`
4. Open an issue on GitHub

---

**Ready to start?** Run `./scripts/setup-local.sh` and you'll be up in minutes! 🚀
