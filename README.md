# LLaMA-Omni2 RunPod Deployment

This repository contains LLaMA-Omni2 configured for deployment on RunPod for real-time speech conversation testing.

## 🚀 Quick Start on RunPod

### Step 1: Build Docker Image

1. Create a RunPod pod with `docker:dind` image
2. SSH into the pod and run:
   ```bash
   git clone https://github.com/Yugandhar-G/speech-speech
   cd speech-speech
   docker login
   docker buildx create --use
   docker buildx build --platform linux/amd64 \
       -t darksoul123/llama-omni2:latest \
       --push .
   ```

### Step 2: Deploy on RunPod

1. Create a new RunPod pod with:
   - **Container Image**: `darksoul123/llama-omni2:latest`
   - **Container Disk**: 20GB+
   - **Volume**: 50GB+ for models
   - **Ports**: 8000, 21001, 40000
   - **GPU**: RTX 3090 or better (24GB+ VRAM)

2. Download models via SSH:
   ```bash
   huggingface-cli download ICTNLP/LLaMA-Omni2-3B-Bilingual \
       --local-dir /workspace/models/LLaMA-Omni2-3B-Bilingual
   
   huggingface-cli download ICTNLP/cosy2_decoder \
       --local-dir /workspace/models/cosy2_decoder
   ```

3. Access the web interface at port 8000

## 📁 Project Structure

- `Dockerfile` - Container image definition
- `start_services.sh` - Automatic service startup script
- `build_and_push.sh` - Docker build and push script
- `RUNPOD_SETUP.md` - Detailed RunPod deployment guide
- `BUILD_ON_RUNPOD.md` - Guide for building on RunPod

## 🔧 Services

The deployment runs three services:
- **Controller** (port 21001) - Manages workers and routes requests
- **Model Worker** (port 40000) - Loads and runs the model
- **Gradio Web Server** (port 8000) - Web interface for interaction

## 📝 Notes

- Models are **not** included in the Docker image (too large)
- Download models after pod creation or mount them as a volume
- Services start automatically when the container starts

## 📚 Documentation

- `RUNPOD_SETUP.md` - Complete RunPod setup instructions
- `BUILD_ON_RUNPOD.md` - Building Docker image on RunPod

## 🔗 Original Project

Based on [LLaMA-Omni2](https://github.com/ictnlp/LLaMA-Omni2) - LLM-based Real-time Spoken Chatbot with Autoregressive Streaming Speech Synthesis.
