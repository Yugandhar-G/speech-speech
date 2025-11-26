#!/bin/bash

set -e

echo "🚀 Starting LLaMA-Omni2 Services..."
echo "===================================="

cd /workspace

# Default configuration
MODEL_NAME=${MODEL_NAME:-"LLaMA-Omni2-3B-Bilingual"}
CONTROLLER_PORT=${CONTROLLER_PORT:-21001}
GRADIO_PORT=${GRADIO_PORT:-8000}
WORKER_PORT=${WORKER_PORT:-40000}
VOCODER_DIR=${VOCODER_DIR:-"/workspace/models/cosy2_decoder"}
MODEL_PATH=${MODEL_PATH:-"/workspace/models/${MODEL_NAME}"}

echo "Configuration:"
echo "  Model: $MODEL_NAME"
echo "  Model Path: $MODEL_PATH"
echo "  Vocoder Dir: $VOCODER_DIR"
echo "  Controller Port: $CONTROLLER_PORT"
echo "  Worker Port: $WORKER_PORT"
echo "  Gradio Port: $GRADIO_PORT"
echo ""

# Wait for models if not present
if [ ! -d "$MODEL_PATH" ]; then
    echo "⚠️  Model not found at: $MODEL_PATH"
    echo "⏳ Waiting for model to be downloaded..."
    echo "   You can download it via SSH:"
    echo "   huggingface-cli download ICTNLP/$MODEL_NAME --local-dir $MODEL_PATH"
    while [ ! -d "$MODEL_PATH" ]; do
        sleep 30
        echo "   Still waiting for model..."
    done
    echo "✅ Model found!"
fi

if [ ! -d "$VOCODER_DIR" ]; then
    echo "⚠️  Vocoder not found at: $VOCODER_DIR"
    echo "⏳ Waiting for vocoder to be downloaded..."
    echo "   You can download it via SSH:"
    echo "   huggingface-cli download ICTNLP/cosy2_decoder --local-dir $VOCODER_DIR"
    while [ ! -d "$VOCODER_DIR" ]; do
        sleep 30
        echo "   Still waiting for vocoder..."
    done
    echo "✅ Vocoder found!"
fi

echo "✅ All models ready"
echo ""

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Shutting down services..."
    kill $CONTROLLER_PID $WORKER_PID $GRADIO_PID 2>/dev/null || true
    wait
    exit 0
}

trap cleanup SIGTERM SIGINT

# Start Controller
echo "🔧 Starting Controller on port $CONTROLLER_PORT..."
python3 -m llama_omni2.serve.controller \
    --host 0.0.0.0 \
    --port $CONTROLLER_PORT \
    --dispatch-method shortest_queue &
CONTROLLER_PID=$!
sleep 3

# Start Model Worker
echo "🤖 Starting Model Worker on port $WORKER_PORT..."
python3 -m llama_omni2.serve.model_worker \
    --host 0.0.0.0 \
    --controller-address http://localhost:$CONTROLLER_PORT \
    --port $WORKER_PORT \
    --worker-address http://localhost:$WORKER_PORT \
    --model-path $MODEL_PATH \
    --model-name $MODEL_NAME \
    --limit-model-concurrency 5 &
WORKER_PID=$!
sleep 5

# Start Gradio Server
echo "🌐 Starting Gradio Web Server on port $GRADIO_PORT..."
python3 -m llama_omni2.serve.gradio_web_server \
    --host 0.0.0.0 \
    --controller-url http://localhost:$CONTROLLER_PORT \
    --port $GRADIO_PORT \
    --vocoder-dir $VOCODER_DIR \
    --concurrency-count 16 &
GRADIO_PID=$!
sleep 2

echo ""
echo "✅ All services started!"
echo "================================"
echo "📊 Service Status:"
echo "   - Controller: http://localhost:$CONTROLLER_PORT"
echo "   - Model Worker: http://localhost:$WORKER_PORT"
echo "   - Gradio UI: http://localhost:$GRADIO_PORT"
echo ""
echo "🌐 Access the web interface at: http://localhost:$GRADIO_PORT"
echo "   (Use RunPod's port forwarding to access from your browser)"
echo ""

# Keep container running
wait

