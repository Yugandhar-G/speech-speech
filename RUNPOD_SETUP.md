# 🚀 RunPod Deployment Guide for LLaMA-Omni2

This guide will help you deploy LLaMA-Omni2 on RunPod for real-time conversation testing.

## Step 1: Build and Push Docker Image

1. **Login to Docker Hub:**
   ```bash
   docker login
   ```

2. **Build and push the image:**
   ```bash
   ./build_and_push.sh
   ```
   
   This will build for `linux/amd64` and push to Docker Hub. Takes 15-25 minutes.

## Step 2: Configure RunPod Pod

1. **Create a new Pod** in RunPod with these settings:

   - **Container Image**: `darksoul123/llama-omni2:latest`
   - **Container Disk**: 20GB (minimum)
   - **GPU**: RTX 3090, A5000, or better (24GB+ VRAM recommended)
   - **Volume**: 50GB+ for models (create a new volume or use existing)
   - **Ports**: 
     - `8000` (Gradio web interface)
     - `21001` (Controller)
     - `40000` (Model Worker)

2. **Environment Variables** (optional, defaults work):
   ```
   MODEL_NAME=LLaMA-Omni2-3B-Bilingual
   CONTROLLER_PORT=21001
   GRADIO_PORT=8000
   WORKER_PORT=40000
   MODEL_PATH=/workspace/models/LLaMA-Omni2-3B-Bilingual
   VOCODER_DIR=/workspace/models/cosy2_decoder
   ```

## Step 3: Download Models

Once the pod starts, SSH into it and download the models:

```bash
# Install huggingface-cli if needed
pip install huggingface-hub

# Download the main model
huggingface-cli download ICTNLP/LLaMA-Omni2-3B-Bilingual \
    --local-dir /workspace/models/LLaMA-Omni2-3B-Bilingual

# Download CosyVoice 2 decoder
huggingface-cli download ICTNLP/cosy2_decoder \
    --local-dir /workspace/models/cosy2_decoder

# Download Whisper encoder
python3 -c "import whisper; whisper.load_model('large-v3', download_root='/workspace/models/speech_encoder/')"
```

**Note:** If you have models in a volume, mount the volume to `/workspace/models` instead.

## Step 4: Access the Web Interface

1. The services will start automatically when the container starts
2. Use RunPod's **Connect** button to get the public URL
3. Or use port forwarding: `http://<pod-ip>:8000`

## Step 5: Test Real-time Conversation

1. Open the Gradio interface in your browser
2. Click the microphone icon to record audio
3. Or upload an audio file
4. The model will respond with both text and speech!

## Troubleshooting

### Services not starting
- Check logs: The container logs will show service startup
- SSH in and check: `ps aux | grep python`
- Manually start: Run `/workspace/start_services.sh` in SSH

### Models not found
- Verify models are in `/workspace/models/`
- Check volume mount path
- Re-download if needed

### Port issues
- Ensure ports 8000, 21001, 40000 are exposed in RunPod
- Check firewall settings

## Manual Service Start (if needed)

If services don't start automatically, SSH in and run:

```bash
cd /workspace
./start_services.sh
```

Or start individually:

```bash
# Terminal 1: Controller
python3 -m llama_omni2.serve.controller --host 0.0.0.0 --port 21001 &

# Terminal 2: Model Worker
python3 -m llama_omni2.serve.model_worker \
    --host 0.0.0.0 \
    --controller-address http://localhost:21001 \
    --port 40000 \
    --worker-address http://localhost:40000 \
    --model-path /workspace/models/LLaMA-Omni2-3B-Bilingual \
    --model-name LLaMA-Omni2-3B-Bilingual &

# Terminal 3: Gradio
python3 -m llama_omni2.serve.gradio_web_server \
    --host 0.0.0.0 \
    --controller-url http://localhost:21001 \
    --port 8000 \
    --vocoder-dir /workspace/models/cosy2_decoder
```

## Notes

- Models are **NOT** included in the Docker image (too large)
- Download models after the pod starts or mount them as a volume
- The container will exit if models are missing - download them first or mount a volume
- For better performance, use a GPU with 24GB+ VRAM

