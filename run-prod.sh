#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Print banner
echo -e "${BLUE}"
echo "================================================"
echo "          NFT Bidding Bot Deployment             "
echo "================================================"
echo -e "${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    cat > .env << EOL
# MongoDB Configuration
MONGODB_URI=mongodb://mongodb:27017/nftbot
REDIS_URI=redis://redis:6379

# Authentication
JWT_SECRET=${JWT_SECRET:-"your-secret-key"}

# API Keys
ALCHEMY_API_KEY=${ALCHEMY_API_KEY:-""}

# Email Configuration
EMAIL_USERNAME=${EMAIL_USERNAME:-""}
EMAIL_PASSWORD=${EMAIL_PASSWORD:-""}

# URLs
CLIENT_URL=http://localhost:3001
NEXT_PUBLIC_CLIENT_URL=http://localhost:3001
NEXT_PUBLIC_SERVER_WEBSOCKET=ws://localhost:3003
EOL
fi

# Pull latest images
echo -e "${BLUE}Pulling latest images...${NC}"
docker compose -f compose.prod.yaml pull

# Start the application
echo -e "${BLUE}Starting the application in watch mode...${NC}"
docker compose -f compose.prod.yaml up --build --watch

echo -e "${GREEN}Application started successfully!${NC}"
echo -e "Client: http://localhost:3001"
echo -e "Server: http://localhost:3003" 