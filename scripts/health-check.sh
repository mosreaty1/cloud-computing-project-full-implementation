#!/bin/bash

echo "================================"
echo "Health Check - All Services"
echo "================================"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check service health
check_service() {
    local name=$1
    local url=$2

    echo -n "Checking $name... "

    response=$(curl -s -o /dev/null -w "%{http_code}" $url 2>&1)

    if [ "$response" = "200" ]; then
        echo -e "${GREEN}✓ Healthy${NC}"
        return 0
    else
        echo -e "${RED}✗ Unhealthy (HTTP $response)${NC}"
        return 1
    fi
}

# Check if running locally or on AWS
if [ -z "$ALB_DNS" ]; then
    BASE_URL="http://localhost:8000"
    echo "Checking local services..."
else
    BASE_URL="http://$ALB_DNS"
    echo "Checking AWS services at $ALB_DNS..."
fi

echo ""

# Check API Gateway
check_service "API Gateway" "$BASE_URL/health"

# Check individual services
check_service "TTS Service" "http://localhost:8001/health" || \
check_service "TTS Service" "$BASE_URL/api/tts/health"

check_service "STT Service" "http://localhost:8002/health" || \
check_service "STT Service" "$BASE_URL/api/stt/health"

check_service "Chat Service" "http://localhost:8003/health" || \
check_service "Chat Service" "$BASE_URL/api/chat/health"

check_service "Document Reader" "http://localhost:8004/health" || \
check_service "Document Reader" "$BASE_URL/api/documents/health"

check_service "Quiz Service" "http://localhost:8005/health" || \
check_service "Quiz Service" "$BASE_URL/api/quiz/health"

echo ""

# Check infrastructure services
echo "Checking infrastructure services..."
echo ""

check_service "Kafka" "http://localhost:9092" 2>/dev/null || echo -e "${YELLOW}⚠ Kafka check skipped${NC}"
check_service "PostgreSQL" "localhost:5432" 2>/dev/null || echo -e "${YELLOW}⚠ PostgreSQL check skipped${NC}"

echo ""
echo "================================"
echo "Health check complete"
echo "================================"
