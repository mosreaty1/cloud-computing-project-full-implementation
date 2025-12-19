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

### Required Software
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

### 1. Clone and Setup

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

- [AWS Infrastructure Setup Guide](docs/guides/AWS-SETUP-GUIDE.md)
- [Microservices Architecture](docs/architecture/MICROSERVICES.md)
- [Kafka Event Patterns](docs/architecture/KAFKA-EVENTS.md)
- [API Documentation](docs/api/API-REFERENCE.md)
- [Deployment Guide](docs/guides/DEPLOYMENT-GUIDE.md)
- [Troubleshooting](docs/guides/TROUBLESHOOTING.md)

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
