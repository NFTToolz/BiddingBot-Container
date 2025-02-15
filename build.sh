#!/bin/bash
REGISTRY="ayenisholah"
VERSION="latest"  # Allow version override

# Build and tag both images
build_images() {
    echo "Building Docker images..."
    docker build -t $REGISTRY/bidding-bot-server:$VERSION -f Dockerfile .
    docker build -t $REGISTRY/bidding-bot-client:$VERSION -f client/Dockerfile ./client
}

# Push both images
push_images() {
    echo "Pushing Docker images..."
    docker push $REGISTRY/bidding-bot-server:$VERSION
    docker push $REGISTRY/bidding-bot-client:$VERSION
}

case "$1" in
    "build")
        build_images
        ;;
    "push")
        push_images
        ;;
    "all")
        build_images
        push_images
        ;;
    *)
        echo "Usage: $0 {build|push|all} [version]"
        exit 1
        ;;
esac