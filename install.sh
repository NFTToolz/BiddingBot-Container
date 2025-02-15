#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Repository and version information
REGISTRY="ayenisholah"
VERSION="latest"
# GIST_ID="17c37d1c609f4122e45ce0c7d02dad0f"
# GIST_URL="https://gist.githubusercontent.com/ayenisholah/${GIST_ID}/raw"

echo -e "${GREEN}NFT Bidding Bot Installation Script${NC}"
echo "----------------------------------------"

# Check OS
OS=$(uname)
echo -e "${YELLOW}Detected OS: $OS${NC}"

# Check Docker installation
if ! [ -x "$(command -v docker)" ]; then
    echo -e "${YELLOW}Docker not found. Installing Docker...${NC}"
    if [ "$OS" = "Linux" ]; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
    elif [ "$OS" = "Darwin" ]; then
        echo -e "${RED}Please install Docker Desktop manually from: https://www.docker.com/products/docker-desktop${NC}"
        exit 1
    fi
fi

# Check Docker Compose installation
if ! [ -x "$(command -v docker-compose)" ]; then
    echo -e "${YELLOW}Docker Compose not found.${NC}"
    if [ "$OS" = "Darwin" ]; then
        # Get Docker version for macOS
        DOCKER_VERSION=$(docker version --format '{{.Server.Version}}' 2>/dev/null)
        MAJOR_VERSION=$(echo $DOCKER_VERSION | cut -d. -f1)
        
        if [ "$MAJOR_VERSION" -ge 2 ]; then
            echo -e "${GREEN}Docker version >= 2.0.0 detected. Docker Compose is already included.${NC}"
        else
            echo -e "${YELLOW}Installing Docker Compose...${NC}"
            sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
        fi
    else
        echo -e "${YELLOW}Installing Docker Compose...${NC}"
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
fi

# Create project directory
PROJECT_DIR="nft-bidding-bot"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Download necessary files
echo -e "${YELLOW}Downloading configuration files...${NC}"
curl -s "https://gist.githubusercontent.com/ayenisholah/285a688f867b175fc9eaf8f996dfbfef/raw/4d42d860b722c23ed2b6ff33b9bf186ba3ba8013/compose.prod.yaml?_=$(uuidgen)" -o compose.prod.yaml
curl -s "https://gist.githubusercontent.com/ayenisholah/689818bdd1d65c761f8a1a124b4f2220/raw/2b0ff21cd85f31e66f5dd216fc20e1a8b83068a3/Dockerfile?_=$(uuidgen)" -o Dockerfile
curl -s "https://gist.githubusercontent.com/ayenisholah/4a90a31842456f2eb1d26656cfe67c8b/raw/6715777ffcfc6d04cbccb93c294fc75ed6728486/package.json?_=$(uuidgen)" -o package.json
# Create .env file
cat > .env << EOL
MONGODB_URI=mongodb://mongodb:27017/BIDDING_BOT
PORT_SERVER=3003
PORT_CLIENT=3001
EOL

# Pull Docker images
# echo -e "${YELLOW}Pulling Docker images...${NC}"
# docker pull ${REGISTRY}/bidding-bot-server:${VERSION}
# docker pull ${REGISTRY}/bidding-bot-client:${VERSION}
# docker pull mongo:latest
# docker pull redis:latest

# Start services
echo -e "${YELLOW}Starting services...${NC}"
docker compose -f compose.prod.yaml build  && docker compose -f compose.prod.yaml up --watch

# Check health
echo -e "${YELLOW}Checking service health...${NC}"
sleep 10

if curl -s http://localhost:3003/health > /dev/null; then
    echo -e "${GREEN}Server is healthy!${NC}"
else
    echo -e "${RED}Server health check failed${NC}"
fi

if curl -s http://localhost:3001 > /dev/null; then
    echo -e "${GREEN}Client is accessible!${NC}"
else
    echo -e "${RED}Client health check failed${NC}"
fi

echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "Server running at: http://localhost:3003"
echo -e "Client running at: http://localhost:3001"
echo -e "\nUseful commands:"
echo -e "${YELLOW}cd $PROJECT_DIR${NC}"
echo -e "${YELLOW}docker-compose -f compose.prod.yaml ps${NC} - Check service status"
echo -e "${YELLOW}docker-compose -f compose.prod.yaml logs${NC} - View logs"
echo -e "${YELLOW}docker-compose -f compose.prod.yaml down${NC} - Stop services"