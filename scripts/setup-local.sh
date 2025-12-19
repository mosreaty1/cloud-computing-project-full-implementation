#!/bin/bash
set -e

echo "==================================="
echo "Cloud Learning Platform - Local Setup"
echo "==================================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."

command -v docker >/dev/null 2>&1 || { echo "Error: Docker is not installed"; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo "Error: Docker Compose is not installed"; exit 1; }

echo "✓ Docker installed: $(docker --version)"
echo "✓ Docker Compose installed: $(docker-compose --version)"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "✓ Created .env file"
    echo "⚠️  Please edit .env and add your API keys"
    echo ""
fi

# Check for required environment variables
if ! grep -q "OPENAI_API_KEY=sk-" .env 2>/dev/null; then
    echo "⚠️  Warning: OPENAI_API_KEY not set in .env"
    echo "   The Chat, Document Reader, and Quiz services require an OpenAI API key"
    echo ""
fi

# Create necessary directories
echo "Creating necessary directories..."
mkdir -p services/{tts-service,stt-service,chat-service,document-reader,quiz-service,api-gateway}/src/services
mkdir -p data/{kafka,postgres,redis}
echo "✓ Directories created"
echo ""

# Make scripts executable
echo "Making scripts executable..."
chmod +x scripts/*.sh
chmod +x infrastructure/modules/ec2/userdata/*.sh
echo "✓ Scripts are executable"
echo ""

echo "==================================="
echo "Setup complete! Next steps:"
echo "==================================="
echo ""
echo "1. Edit .env file with your configuration:"
echo "   nano .env"
echo ""
echo "2. Start all services locally:"
echo "   docker-compose up -d"
echo ""
echo "3. Check service health:"
echo "   ./scripts/health-check.sh"
echo ""
echo "4. View logs:"
echo "   docker-compose logs -f"
echo ""
echo "5. Stop services:"
echo "   docker-compose down"
echo ""
echo "For AWS deployment, see: docs/guides/AWS-SETUP-GUIDE.md"
echo ""
