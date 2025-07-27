#!/bin/bash

# Configuration for Mac testing
IMAGE_NAME="comfyui-mac"
TAG="test"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== ComfyUI Mac Testing Build ===${NC}"
echo -e "${YELLOW}Building CPU-only version for Mac validation${NC}"
echo "Image: $IMAGE_NAME:$TAG"
echo ""

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running!${NC}"
    echo "Please start Docker Desktop and try again."
    exit 1
fi

# Validate configuration files
echo -e "${YELLOW}Validating configuration files...${NC}"

if [ ! -f "custom_nodes.txt" ]; then
    echo -e "${RED}Error: custom_nodes.txt not found!${NC}"
    exit 1
fi

if [ ! -f "models.txt" ]; then
    echo -e "${RED}Error: models.txt not found!${NC}"
    exit 1
fi

# Count items to be installed
CUSTOM_NODES=$(grep -v "^#" custom_nodes.txt | grep -v "^$" | wc -l | tr -d ' ')
MODELS=$(grep -v "^#" models.txt | grep -v "^$" | wc -l | tr -d ' ')

echo "Custom nodes to install: $CUSTOM_NODES"
echo "Models to download: $MODELS"
echo ""

# Build the Docker image using Mac Dockerfile
echo -e "${GREEN}Starting Docker build (Mac version)...${NC}"
echo "This may take a while due to model downloads..."
echo ""

docker build -f Dockerfile.mac -t $IMAGE_NAME:$TAG .

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Mac build completed successfully!${NC}"
    echo ""
    echo "Image details:"
    docker images $IMAGE_NAME:$TAG

    echo ""
    echo -e "${GREEN}Ready for Mac testing!${NC}"
    echo ""
    echo "To run test container:"
    echo "./run_mac.sh"
    echo ""
    echo -e "${YELLOW}Note: This validates the build process only.${NC}"
    echo -e "${YELLOW}GPU operations will not work on Mac.${NC}"

else
    echo -e "${RED}✗ Build failed!${NC}"
    echo ""
    echo "Check the build logs above for errors."
    exit 1
fi
