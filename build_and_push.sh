#!/bin/bash

# Build and push Docker image for RunPod

IMAGE_NAME="darksoul123/llama-omni2:latest"

echo "🔨 Building Docker image for RunPod..."
echo "======================================"

# Setup buildx
docker buildx create --name runpod-builder --use --driver docker-container 2>/dev/null || \
    docker buildx use runpod-builder

# Build and push with retry
MAX_RETRIES=3
RETRY=0

while [ $RETRY -lt $MAX_RETRIES ]; do
    echo ""
    if [ $RETRY -eq 0 ]; then
        echo "🏗️  Building and pushing for linux/amd64..."
        echo "   This may take 15-25 minutes..."
    else
        echo "🔄 Retry attempt $RETRY/$MAX_RETRIES..."
    fi
    
    if docker buildx build \
        --platform linux/amd64 \
        --tag $IMAGE_NAME \
        --push \
        .; then
        echo ""
        echo "✅ Success! Image: $IMAGE_NAME"
        echo "   Ready to use in RunPod!"
        exit 0
    else
        RETRY=$((RETRY + 1))
        if [ $RETRY -lt $MAX_RETRIES ]; then
            echo ""
            echo "⚠️  Push failed. Waiting 30 seconds before retry..."
            sleep 30
        else
            echo ""
            echo "❌ Failed after $MAX_RETRIES attempts."
            echo ""
            echo "💡 Alternative: Build directly on RunPod (see BUILD_ON_RUNPOD.md)"
            echo "   This avoids network issues from your local machine."
            exit 1
        fi
    fi
done

