#!/bin/bash

# Configuration
IMAGE_NAME="my-comfyui"
TAG="latest"
CONTAINER_NAME="comfyui-test"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Running ComfyUI locally for testing${NC}"

# Stop existing container
docker stop $CONTAINER_NAME 2>/dev/null
docker rm $CONTAINER_NAME 2>/dev/null

# Run container
docker run -d \
    --name $CONTAINER_NAME \
    --gpus all \
    -p 8188:8188 \
    -e RUNPOD_POD_ID="local-test" \
    $IMAGE_NAME:$TAG

echo ""
echo -e "${GREEN}Container started!${NC}"
echo "Access ComfyUI at: http://localhost:8188"
echo ""
echo "To view logs: docker logs -f $CONTAINER_NAME"
echo "To stop: docker stop $CONTAINER_NAME"

# Show initial logs
sleep 3
echo -e "${YELLOW}Container logs:${NC}"
docker logs $CONTAINER_NAME
