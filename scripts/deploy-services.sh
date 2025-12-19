#!/bin/bash
set -e

ENVIRONMENT=${1:-dev}

echo "========================================"
echo "Deploying Services to $ENVIRONMENT"
echo "========================================"
echo ""

# Check if kubectl is available
if command -v kubectl &> /dev/null; then
    echo "Using Kubernetes deployment..."

    # Apply namespace
    kubectl apply -f kubernetes/base/namespace.yaml

    # Create ECR secret for pulling images
    echo "Creating ECR authentication secret..."
    kubectl create secret docker-registry ecr-secret \
        --docker-server=$(aws ecr get-login-password --region us-east-1 | base64 -d | docker-credential-ecr-login get) \
        --docker-username=AWS \
        --docker-password=$(aws ecr get-login-password --region us-east-1) \
        --namespace=learning-platform \
        --dry-run=client -o yaml | kubectl apply -f -

    # Create application secrets
    kubectl create secret generic app-secrets \
        --from-literal=jwt-secret=${JWT_SECRET:-change-me-in-production} \
        --from-literal=openai-api-key=${OPENAI_API_KEY} \
        --namespace=learning-platform \
        --dry-run=client -o yaml | kubectl apply -f -

    # Apply all service manifests
    echo "Deploying services..."
    kubectl apply -f kubernetes/base/

    # Wait for deployments
    echo "Waiting for deployments to be ready..."
    kubectl wait --for=condition=available --timeout=300s \
        deployment --all -n learning-platform

    # Get service URLs
    echo ""
    echo "========================================"
    echo "Deployment Complete!"
    echo "========================================"
    echo ""
    echo "Service endpoints:"
    kubectl get services -n learning-platform

else
    echo "kubectl not found, using Docker Swarm..."

    # Initialize swarm if not already
    docker swarm init 2>/dev/null || true

    # Deploy using docker stack
    docker stack deploy -c docker-compose.yml learning-platform

    echo ""
    echo "========================================"
    echo "Deployment Complete!"
    echo "========================================"
    echo ""
    echo "Services:"
    docker service ls
fi

echo ""
echo "Next steps:"
echo "  1. Check health: ./scripts/health-check.sh"
echo "  2. View logs: kubectl logs -f deployment/api-gateway -n learning-platform"
echo "  3. Access API: http://<load-balancer-ip>/"
echo ""
