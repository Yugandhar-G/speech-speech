# Build Docker Image on RunPod

Since pushing from your local machine has network issues, build directly on RunPod:

## Steps:

1. **Create a temporary RunPod Pod for building:**
   - Template: Any GPU template (even a small one)
   - Container Image: `docker:dind` (Docker-in-Docker)
   - Container Disk: 20GB+
   - Enable Docker socket

2. **SSH into the pod and run:**
   ```bash
   # Install git and dependencies
   apk add git python3 py3-pip
   
   # Clone your repo (or upload files via RunPod's file manager)
   git clone <your-repo-url>
   cd LLaMA-Omni2
   
   # Or if you uploaded files, they should be in /workspace
   cd /workspace
   
   # Login to Docker Hub
   docker login
   
   # Build and push
   docker buildx create --use
   docker buildx build --platform linux/amd64 \
       -t darksoul123/llama-omni2:latest \
       --push .
   ```

3. **Once the image is pushed, create your main RunPod pod** with:
   - Container Image: `darksoul123/llama-omni2:latest`
   - Follow the steps in `RUNPOD_SETUP.md`

This way the build happens on a machine with better network to Docker Hub!

