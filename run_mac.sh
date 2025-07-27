#!/bin/bash

# Configuration for Mac testing
IMAGE_NAME="comfyui-mac"
TAG="test"
CONTAINER_NAME="comfyui-mac-test"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Running ComfyUI on Mac (CPU mode for testing)${NC}"

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running!${NC}"
    echo "Please start Docker Desktop and try again."
    exit 1
fi

# Stop existing container
docker stop $CONTAINER_NAME 2>/dev/null
docker rm $CONTAINER_NAME 2>/dev/null

# Run container (no GPU flags for Mac)
docker run -d \
    --name $CONTAINER_NAME \
    -p 8188:8188 \
    $IMAGE_NAME:$TAG

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}Container started successfully!${NC}"
    echo "Access ComfyUI at: http://localhost:8188"
    echo ""
    echo -e "${YELLOW}Note: This is CPU-only mode for testing${NC}"
    echo -e "${YELLOW}Image generation will not work without GPU${NC}"
    echo ""
    echo "To view logs: docker logs -f $CONTAINER_NAME"
    echo "To stop: docker stop $CONTAINER_NAME"

    # Show initial logs
    sleep 3
    echo -e "${YELLOW}Container startup logs:${NC}"
    docker logs $CONTAINER_NAME
else
    echo -e "${RED}✗ Failed to start container!${NC}"
    exit 1
fi
