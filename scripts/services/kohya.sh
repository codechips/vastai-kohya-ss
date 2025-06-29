#!/usr/bin/env bash
# Kohya SS service

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

function setup_kohya_workspace() {
    # Create Kohya SS specific directories in workspace
    echo "kohya: setting up workspace directories..."
    mkdir -p "${WORKSPACE}/kohya_ss/models"
    mkdir -p "${WORKSPACE}/kohya_ss/dataset"
    mkdir -p "${WORKSPACE}/kohya_ss/outputs"
    mkdir -p "${WORKSPACE}/kohya_ss/logs"
    mkdir -p "${WORKSPACE}/kohya_ss/reg"
    mkdir -p "${WORKSPACE}/kohya_ss/config"
    
    # Create symlinks from Kohya SS directories to workspace
    echo "kohya: creating symlinks to workspace..."
    if [ ! -L "/opt/kohya_ss/models" ]; then
        ln -sf "${WORKSPACE}/kohya_ss/models" "/opt/kohya_ss/models"
    fi
    if [ ! -L "/opt/kohya_ss/outputs" ]; then
        ln -sf "${WORKSPACE}/kohya_ss/outputs" "/opt/kohya_ss/outputs"
    fi
    if [ ! -L "/opt/kohya_ss/logs" ]; then
        ln -sf "${WORKSPACE}/kohya_ss/logs" "/opt/kohya_ss/logs"
    fi
    if [ ! -L "/opt/kohya_ss/reg" ]; then
        ln -sf "${WORKSPACE}/kohya_ss/reg" "/opt/kohya_ss/reg"
    fi
    # Note: dataset symlink matches Kohya SS expected structure
    if [ ! -L "/opt/kohya_ss/dataset" ]; then
        ln -sf "${WORKSPACE}/kohya_ss/dataset" "/opt/kohya_ss/dataset"
    fi
    
    echo "kohya: workspace setup completed"
}

function start_kohya() {
    echo "kohya: starting Kohya SS GUI with UV package manager"

    # Activate the uv-created virtual environment
    cd /opt/kohya_ss
    source .venv/bin/activate

    # Setup workspace directories and symlinks
    setup_kohya_workspace

    # Prepare default arguments for Kohya SS GUI
    DEFAULT_ARGS="--listen 0.0.0.0 --server_port 8010 --headless --noverify"

    # Enable authentication if credentials are provided
    if [[ ${USERNAME} ]] && [[ ${PASSWORD} ]]; then
        echo "kohya: enabling authentication for user: ${USERNAME}"
        DEFAULT_ARGS="${DEFAULT_ARGS} --username ${USERNAME} --password ${PASSWORD}"
    else
        echo "kohya: starting without authentication (no USERNAME/PASSWORD set)"
        echo "kohya: WARNING - will be accessible externally without authentication"
        echo "kohya: set USERNAME and PASSWORD environment variables to enable authentication"
    fi

    # Combine default args with any custom args
    FULL_ARGS="${DEFAULT_ARGS} ${KOHYA_ARGS}"

    # Prepare TCMalloc for better memory performance
    prepare_tcmalloc

    echo "kohya: launching Kohya SS GUI with args: ${FULL_ARGS}"
    
    # Launch Kohya SS using UV
    nohup uv run kohya_gui.py ${FULL_ARGS} >${WORKSPACE}/logs/kohya.log 2>&1 &

    echo "kohya: started on port 8010"
    echo "kohya: log file at ${WORKSPACE}/logs/kohya.log"
    echo "kohya: workspace directories at ${WORKSPACE}/kohya_ss/"
    echo "kohya: - models: ${WORKSPACE}/kohya_ss/models"
    echo "kohya: - dataset: ${WORKSPACE}/kohya_ss/dataset"
    echo "kohya: - outputs: ${WORKSPACE}/kohya_ss/outputs"
    echo "kohya: - logs: ${WORKSPACE}/kohya_ss/logs"
    echo "kohya: - regularization: ${WORKSPACE}/kohya_ss/reg"
    echo "kohya: - config: ${WORKSPACE}/kohya_ss/config"
}

# Note: Function is called explicitly from start.sh
# No auto-execution when sourced to prevent duplicate processes