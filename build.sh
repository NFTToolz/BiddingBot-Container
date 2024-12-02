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


#!/bin/bash
REGISTRY="ayenisholah"   
VERSION="latest"

case "$1" in
    "build")
        echo "Building combined image..."
        docker build -t $REGISTRY/bidding-bot-server:$VERSION ./server
        docker build -t $REGISTRY/bidding-bot-client:$VERSION ./client
        docker build -t $REGISTRY/bidding-bot:$VERSION .
        ;;
    "push")
        echo "Pushing combined image..."
        docker push $REGISTRY/bidding-bot-server:$VERSION
        docker push $REGISTRY/bidding-bot-client:$VERSION
        docker push $REGISTRY/bidding-bot:$VERSION
        ;;
    "all")
        echo "Building and pushing combined image..."
        docker build -t $REGISTRY/bidding-bot-server:$VERSION ./server
        docker build -t $REGISTRY/bidding-bot-client:$VERSION ./client
        docker build -t $REGISTRY/bidding-bot:$VERSION .
        docker push $REGISTRY/bidding-bot-server:$VERSION
        docker push $REGISTRY/bidding-bot-client:$VERSION
        docker push $REGISTRY/bidding-bot:$VERSION
        ;;
    *)
        echo "Usage: $0 {build|push|all}"
        exit 1
        ;;
esac