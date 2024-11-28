#!/bin/bash
REGISTRY="ayenisholah"   
PROJECT=""           
VERSION="latest"

# Build images
docker build -t $REGISTRY/bidding-bot-server:$VERSION ./server
docker build -t $REGISTRY/bidding-bot-client:$VERSION ./client

# Push images to registry
docker push $REGISTRY/bidding-bot-server:$VERSION
docker push $REGISTRY/bidding-bot-client:$VERSION