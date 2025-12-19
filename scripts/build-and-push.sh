#!/bin/bash
set -e

echo "========================================"
echo "Building and Pushing Docker Images"
echo "========================================"
echo ""

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "Error: AWS credentials not configured"
    echo "Run: aws configure"
    exit 1
fi

# Get AWS account ID and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=${AWS_REGION:-us-east-1}
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "AWS Account: $AWS_ACCOUNT_ID"
echo "AWS Region: $AWS_REGION"
echo "ECR Registry: $ECR_REGISTRY"
echo ""

# Login to ECR
echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | \
    docker login --username AWS --password-stdin $ECR_REGISTRY

# Services to build
SERVICES=(
    "tts-service"
    "stt-service"
    "chat-service"
    "document-reader"
    "quiz-service"
    "api-gateway"
)

# Build and push each service
for service in "${SERVICES[@]}"; do
    echo ""
    echo "========================================"
    echo "Building $service"
    echo "========================================"

    # Check if service directory exists
    if [ ! -d "services/$service" ]; then
        echo "Warning: services/$service directory not found, skipping..."
        continue
    fi

    # Repository name
    REPO_NAME="learning-platform/$service"

    # Create ECR repository if it doesn't exist
    echo "Ensuring ECR repository exists: $REPO_NAME"
    aws ecr describe-repositories --repository-names $REPO_NAME --region $AWS_REGION 2>&1 || \
        aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION

    # Build image
    echo "Building Docker image for $service..."
    cd services/$service
    docker build -t $service:latest .

    # Tag image
    IMAGE_TAG=$(date +%Y%m%d-%H%M%S)
    echo "Tagging image with tags: latest, $IMAGE_TAG"
    docker tag $service:latest $ECR_REGISTRY/$REPO_NAME:latest
    docker tag $service:latest $ECR_REGISTRY/$REPO_NAME:$IMAGE_TAG

    # Push images
    echo "Pushing images to ECR..."
    docker push $ECR_REGISTRY/$REPO_NAME:latest
    docker push $ECR_REGISTRY/$REPO_NAME:$IMAGE_TAG

    echo "✓ Successfully built and pushed $service"
    cd ../..
done

echo ""
echo "========================================"
echo "All images built and pushed successfully!"
echo "========================================"
echo ""
echo "Images pushed to:"
for service in "${SERVICES[@]}"; do
    echo "  - $ECR_REGISTRY/learning-platform/$service:latest"
done
echo ""
echo "Next steps:"
echo "  1. Deploy services: ./scripts/deploy-services.sh dev"
echo "  2. Check health: ./scripts/health-check.sh"
echo ""
