#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Print banner
echo -e "${BLUE}"
echo "================================================"
echo "          NFT Bidding Bot Installer              "
echo "================================================"
echo -e "${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Create docker-compose.yml
cat > docker-compose.yml << 'EOL'
services:
  server:
    build:
      context: ./server
      dockerfile: Dockerfile
    restart: always
    ports:
      - "3003:3003"
    env_file:
      - .env
    environment:
      PORT: 3003
    depends_on:
      - mongodb
      - redis
    networks:
      - nft_network

  client:
    build:
      context: ./client
      dockerfile: Dockerfile
    restart: always
    ports:
      - "3001:3001"
    env_file:
      - .env
    environment:
      PORT: 3001
      NEXT_PUBLIC_SERVER_WEBSOCKET: "ws://localhost:3003"
    depends_on:
      - mongodb
      - server
      - redis
    networks:
      - nft_network

  mongodb:
    image: mongo:latest
    restart: unless-stopped
    volumes:
      - mongodb_data:/data/db
    networks:
      - nft_network

  redis:
    image: redis:latest
    restart: unless-stopped
    volumes:
      - redis_data:/data
    networks:
      - nft_network

volumes:
  mongodb_data:
  redis_data:

networks:
  nft_network:
    driver: bridge
EOL

# Create .env file
cat > .env << EOL
# Required API Keys
OPENSEA_API_KEY=${OPENSEA_API_KEY:-""}
ALCHEMY_API_KEY=${ALCHEMY_API_KEY:-""}

# Database Configuration
MONGODB_URI=mongodb://mongodb:27017/nftbot
REDIS_URI=redis://redis:6379

# Authentication
JWT_SECRET=${JWT_SECRET:-"your-secret-key"}

# Email Configuration
EMAIL_USERNAME=${EMAIL_USERNAME:-""}
EMAIL_PASSWORD=${EMAIL_PASSWORD:-""}

# URLs
CLIENT_URL=http://localhost:3001
NEXT_PUBLIC_CLIENT_URL=http://localhost:3001
NEXT_PUBLIC_SERVER_WEBSOCKET=ws://localhost:3003
EOL

# Clone repositories
echo -e "${BLUE}Cloning repositories...${NC}"
git clone https://github.com/NFTToolz/BiddingBot-Server.git server
git clone https://github.com/NFTToolz/BiddingBot.git client

# Start the application
echo -e "${BLUE}Starting the application...${NC}"
docker compose up -d --build

# Wait for services to be ready
echo -e "${BLUE}Waiting for services to start...${NC}"
sleep 10

# Check if services are running
if docker compose ps | grep -q "running"; then
    echo -e "${GREEN}"
    echo "================================================"
    echo "NFT Bidding Bot is now running!"
    echo "Open your browser and navigate to:"
    echo "http://localhost:3001"
    echo ""
    echo "To stop the application, run:"
    echo "docker compose down"
    echo "================================================"
    echo -e "${NC}"
else
    echo -e "${RED}Error: Services failed to start properly${NC}"
    docker compose logs
    exit 1
fi