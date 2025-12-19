# Cloud-Based Learning Platform - Full Implementation

A comprehensive cloud-based learning platform integrating AI-powered educational services with enterprise-grade AWS infrastructure, event-driven architecture using Kafka, and containerized microservices.

## 🏗️ Architecture Overview

This platform consists of:
- **5 Microservices**: TTS, STT, Chat, Document Reader, Quiz Service
- **Event-Driven Architecture**: Apache Kafka for service communication
- **AWS Infrastructure**: EC2, S3, RDS, VPC, Lambda, ELB, IAM
- **Containerization**: Docker + Kubernetes
- **API Gateway**: Kong for centralized routing
- **CI/CD**: GitHub Actions for automated deployment

## 📋 Table of Contents

1. [Project Structure](#project-structure)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [AWS Setup Guide](#aws-setup-guide)
5. [Local Development](#local-development)
6. [Deployment](#deployment)
7. [Services Documentation](#services-documentation)
8. [Troubleshooting](#troubleshooting)

## 📁 Project Structure

```
.
├── infrastructure/          # Terraform AWS infrastructure
│   ├── modules/            # Reusable Terraform modules
│   ├── environments/       # Environment-specific configs
│   └── scripts/            # Helper scripts
├── services/               # Microservices
│   ├── tts-service/       # Text-to-Speech
│   ├── stt-service/       # Speech-to-Text
│   ├── chat-service/      # Chat Completion
│   ├── document-reader/   # Document Processing
│   ├── quiz-service/      # Quiz Generation
│   └── api-gateway/       # Kong API Gateway
├── kafka/                  # Kafka cluster configuration
├── kubernetes/             # K8s manifests
├── ci-cd/                 # GitHub Actions workflows
├── docs/                  # Documentation
├── scripts/               # Deployment and utility scripts
└── docker-compose.yml     # Local development setup
```

## 🔧 Prerequisites

### For Windows Users 🪟
**See [Windows Setup Guide](docs/guides/WINDOWS-SETUP-GUIDE.md) for detailed Windows instructions!**

Quick install for Windows:
- **Docker Desktop**: https://www.docker.com/products/docker-desktop/
- **AWS CLI**: https://awscli.amazonaws.com/AWSCLIV2.msi
- **Git**: https://git-scm.com/download/win
- **Terraform**: `choco install terraform` (or manual download)

### For Linux/Mac Users
- AWS CLI v2+
- Terraform v1.5+
- Docker v20+
- kubectl v1.28+
- Python 3.11+
- Node.js 18+ (for some utilities)

### AWS Requirements
- AWS Account with appropriate permissions
- AWS credentials configured (`aws configure`)
- Available budget for resources (estimated $200-500/month for dev)

### API Keys (for AI Services)
- OpenAI API Key (for Chat, Document Reader, Quiz services)
- Alternative: Configure local models (Whisper, etc.)

## 🚀 Quick Start

### For Windows Users 🪟

```powershell
# 1. Clone repository
git clone <repository-url>
cd cloud-computing-project-full-implementation

# 2. Run setup script
.\scripts\setup-local.ps1

# 3. Configure .env file
notepad .env
# Add your OPENAI_API_KEY

# 4. Start services
docker-compose up -d

# 5. Check health
.\scripts\health-check.ps1
```

**See [Quick Start for Windows](docs/guides/QUICK-START-WINDOWS.md) for complete guide!**

### For Linux/Mac Users

```bash
git clone <repository-url>
cd cloud-computing-project-full-implementation

# Install dependencies
./scripts/setup-local.sh
```

### 2. Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit with your AWS and API credentials
nano .env
```

### 3. Local Development (Docker Compose)

```bash
# Start all services locally
docker-compose up -d

# Check service health
./scripts/health-check.sh

# View logs
docker-compose logs -f
```

### 4. Deploy to AWS

```bash
# Initialize Terraform
cd infrastructure/environments/dev
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply

# Deploy services to Kubernetes
./scripts/deploy-services.sh dev
```

## 📚 Documentation Links

### 🪟 Windows Users - Start Here!
- **[Windows Setup Guide](docs/guides/WINDOWS-SETUP-GUIDE.md)** ⭐ Complete Windows guide
- **[Quick Start for Windows](docs/guides/QUICK-START-WINDOWS.md)** ⭐ Get running in 10 minutes

### General Documentation
- [AWS Infrastructure Setup Guide](docs/guides/AWS-SETUP-GUIDE.md)
- [Kafka Event Patterns](docs/architecture/KAFKA-EVENTS.md)
- [Deployment Guide](docs/guides/DEPLOYMENT-GUIDE.md)
- [Project Overview](docs/PROJECT-OVERVIEW.md)
- [Implementation Summary](IMPLEMENTATION-SUMMARY.md)

## 🔐 Security

- All data encrypted at rest and in transit
- IAM roles with least privilege principle
- Isolated storage per service
- VPC with private subnets
- AWS Secrets Manager for credentials

## 📊 Monitoring

- CloudWatch for AWS resources
- Prometheus + Grafana for application metrics
- ELK Stack for log aggregation
- Kafka monitoring dashboard

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## 📄 License

This project is for educational purposes.

## 📞 Support

For issues and questions, refer to the [Troubleshooting Guide](docs/guides/TROUBLESHOOTING.md).
