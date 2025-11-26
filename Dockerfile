FROM nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    python3.10-dev \
    git \
    wget \
    curl \
    ffmpeg \
    libsndfile1 \
    build-essential \
    g++ \
    gcc \
    make \
    procps \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3 /usr/bin/python

WORKDIR /workspace

# Copy project files
COPY . /workspace/

# Install Python dependencies
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel
RUN pip3 install --no-cache-dir Cython ninja
RUN pip3 install --no-cache-dir -e .

# Create directories for models and logs
RUN mkdir -p /workspace/models /workspace/tmp /workspace/logs

# Expose ports
# 8000: Gradio web server
# 21001: Controller
# 40000: Model worker
EXPOSE 8000 21001 40000

# Default command - start all services
CMD ["/bin/bash", "/workspace/start_services.sh"]

