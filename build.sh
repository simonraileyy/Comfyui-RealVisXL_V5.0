#!/bin/bash

# Configuration
IMAGE_NAME="comfyui"
TAG="latest"
REGISTRY="" # Set this if you want to push to a registry (e.g., "your-dockerhub-username/")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== ComfyUI Docker Build Script ===${NC}"
echo -e "${GREEN}Building optimized ComfyUI image for RunPod${NC}"
echo "Image: $REGISTRY$IMAGE_NAME:$TAG"
echo ""

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
CUSTOM_NODES=$(grep -v "^#" custom_nodes.txt | grep -v "^$" | wc -l)
MODELS=$(grep -v "^#" models.txt | grep -v "^$" | wc -l)

echo "Custom nodes to install: $CUSTOM_NODES"
echo "Models to download: $MODELS"
echo ""

# Build the Docker image
echo -e "${GREEN}Starting Docker build...${NC}"
echo "This may take a while due to model downloads..."
echo ""

docker build -t $REGISTRY$IMAGE_NAME:$TAG .

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Build completed successfully!${NC}"
    echo ""
    echo "Image details:"
    docker images $REGISTRY$IMAGE_NAME:$TAG

    # Calculate total size
    SIZE=$(docker images $REGISTRY$IMAGE_NAME:$TAG --format "{{.Size}}")
    echo ""
    echo -e "${BLUE}Image size: $SIZE${NC}"

    echo ""
    echo -e "${GREEN}Ready for RunPod deployment!${NC}"
    echo ""
    echo "To run locally:"
    echo "docker run --gpus all -p 8188:8188 $REGISTRY$IMAGE_NAME:$TAG"
    echo ""
    echo "To push to registry (if configured):"
    echo "docker push $REGISTRY$IMAGE_NAME:$TAG"

else
    echo -e "${RED}✗ Build failed!${NC}"
    echo ""
    echo "Check the build logs above for errors."
    echo "Common issues:"
    echo "- Invalid GitHub URLs in custom_nodes.txt"
    echo "- Invalid Hugging Face model paths in models.txt"
    echo "- Network connectivity issues"
    exit 1
fi
