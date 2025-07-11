# Stage 1: Base with CUDA 12.8
FROM nvidia/cuda:12.8.0-runtime-ubuntu22.04

# Build arguments
ARG DEBIAN_FRONTEND=noninteractive

# Set shell with pipefail for safety
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=on \
    SHELL=/bin/bash \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Install system dependencies (uv will handle Python installation)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    libtcmalloc-minimal4 \
    nginx-light \
    # Additional dependencies for container services
    bc \
    # User tools for debugging and management
    tmux \
    nano \
    vim \
    htop \
    tree \
    libglib2.0-0 && \
    # Clean up apt cache
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install uv for fast package management
RUN curl -LsSf https://astral.sh/uv/install.sh | bash && \
    mv /root/.local/bin/uv /usr/local/bin/uv

# Set CUDA environment
ENV PATH="/usr/local/cuda/bin${PATH:+:${PATH}}"
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64
ENV CUDA_VERSION=12.2
ENV CUDA_HOME=/usr/local/cuda

# Install ttyd and logdy (architecture-aware)
RUN if [ "$(uname -m)" = "x86_64" ]; then \
    curl -L --progress-bar https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.x86_64 -o /usr/local/bin/ttyd && \
    curl -L --progress-bar https://github.com/logdyhq/logdy-core/releases/download/v0.13.0/logdy_linux_amd64 -o /usr/local/bin/logdy; \
    else \
    curl -L --progress-bar https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.aarch64 -o /usr/local/bin/ttyd && \
    curl -L --progress-bar https://github.com/logdyhq/logdy-core/releases/download/v0.13.0/logdy_linux_arm64 -o /usr/local/bin/logdy; \
    fi && \
    chmod +x /usr/local/bin/ttyd /usr/local/bin/logdy

# Install filebrowser and set up directories
RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash && \
    mkdir -p /workspace/logs /opt/kohya_ss /root/.config

# Clone Kohya SS repository
WORKDIR /opt
RUN git clone https://github.com/bmaltais/kohya_ss.git

# Set up Kohya SS working directory
WORKDIR /opt/kohya_ss

# Create Python environment with uv and install dependencies
RUN uv venv --seed --python 3.11 .venv && \
    source .venv/bin/activate && \
    # Update git submodules
    git submodule update --init --recursive && \
    # Install Kohya SS dependencies using UV
    uv sync --frozen

# Clean up build dependencies
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create required directories
RUN mkdir -p /opt/bin /opt/provision /opt/nginx/html /opt/config

# Container runs as root for compatibility with various container runtimes

# Copy configuration files and scripts
COPY config/filebrowser/filebrowser.json /root/.filebrowser.json
COPY config/nginx/sites-available/default /etc/nginx/sites-available/default
COPY scripts/start.sh /opt/bin/start.sh
COPY scripts/services/ /opt/bin/services/
COPY scripts/provision/ /opt/provision/

# Copy HTML templates
COPY config/nginx/html/ /opt/nginx/html/


# Configure filebrowser and set permissions
RUN chmod +x /opt/bin/start.sh /opt/bin/services/*.sh /opt/provision/provision.py && \
    # Capture build metadata
    date -u +"%Y-%m-%dT%H:%M:%SZ" > /root/BUILDTIME.txt && \
    git rev-parse HEAD > /root/BUILD_SHA.txt 2>/dev/null || echo "unknown" > /root/BUILD_SHA.txt && \
    filebrowser config init && \
    filebrowser users add admin admin --perm.admin && \
    # Final cleanup
    find /opt -name "*.pyc" -delete && \
    find /opt -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

# Set environment variables
ENV USERNAME=admin \
    PASSWORD=kohya \
    WORKSPACE=/workspace \
    KOHYA_ARGS="" \
    OPEN_BUTTON_PORT=80

# Expose ports
EXPOSE 80 8010 7010 7020 7030

# Set working directory
WORKDIR /workspace

# Entrypoint
ENTRYPOINT ["/opt/bin/start.sh"]
