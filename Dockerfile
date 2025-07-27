# Use NVIDIA CUDA base image optimized for RunPod
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}
ENV HF_HOME=/app/huggingface_cache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    git \
    wget \
    gnupg \
    curl \
    build-essential \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    git-lfs \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb
RUN dpkg -i cuda-keyring_1.0-1_all.deb
RUN apt-get update && apt-get install -y cuda-toolkit-11-8

# Create working directory
WORKDIR /app

# Clone ComfyUI (latest)
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# Install Python dependencies
RUN pip3 install --no-cache-dir \
    torch==2.1.0 \
    torchvision==0.16.0 \
    torchaudio==2.1.0 \
    --index-url https://download.pytorch.org/whl/cu118

RUN pip3 install --no-cache-dir -r requirements.txt

# Additional dependencies for custom nodes and model downloading
RUN pip3 install --no-cache-dir \
    huggingface-hub \
    opencv-python \
    transformers \
    diffusers \
    accelerate \
    xformers \
    controlnet-aux \
    segment-anything \
    groundingdino-py \
    ultralytics \
    requests \
    tqdm



RUN pip3 install --no-cache-dir xformers==0.0.22
# Copy configuration files
COPY custom_nodes.txt ./
COPY models.txt ./
COPY install_custom_nodes.py ./
COPY download_models.py ./

# Install custom nodes from GitHub URLs
RUN python3 install_custom_nodes.py

# Download models from Hugging Face
RUN python3 download_models.py

# Create startup script for RunPod
RUN echo '#!/bin/bash\n\
echo "=== ComfyUI Starting on RunPod ==="\n\
echo "GPU Info:"\n\
nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader,nounits\n\
echo ""\n\
echo "Disk Space:"\n\
df -h /app\n\
echo ""\n\
echo "Starting ComfyUI server..."\n\
echo "Access URL: https://${RUNPOD_POD_ID}-8188.proxy.runpod.net"\n\
python3 main.py --listen 0.0.0.0 --port 8188 "$@"\n\
' > start.sh && chmod +x start.sh

# Expose port
EXPOSE 8188

# Set default command
CMD ["./start.sh"]
