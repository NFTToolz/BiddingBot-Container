#!/bin/bash

if [ ! -f "./server/.env" ]; then
    echo "Please create server/.env file with required environment variables"
    exit 1
fi

if [ ! -f "./client/.env.local" ]; then
    echo "Please create client/.env.local file with required environment variables"
    exit 1
fi

docker compose pull

# Check if --watch flag is present
if [[ "$1" == "--watch" ]]; then
    docker compose up --watch
else
    docker compose up -d
fi