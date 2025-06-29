#!/usr/bin/env bash
# Main orchestrator for VastAI Kohya SS container services

# Simple process manager for Kohya SS and supporting services
# Modular service architecture for container orchestration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICES_DIR="$SCRIPT_DIR/services"

# Source utilities
source "$SERVICES_DIR/utils.sh"

# Source service scripts
source "$SERVICES_DIR/nginx.sh"
source "$SERVICES_DIR/kohya.sh"
source "$SERVICES_DIR/filebrowser.sh"
source "$SERVICES_DIR/ttyd.sh"
source "$SERVICES_DIR/logdy.sh"
source "$SERVICES_DIR/provisioning.sh"

# Main execution
echo "Starting VastAI Kohya SS container..."

# Setup workspace
setup_workspace

# Run external provisioning first if enabled
run_provisioning

# Start services
start_nginx
start_filebrowser
start_ttyd
start_logdy
start_kohya

# Show information
show_info

# Keep container running
echo ""
echo "Container is running. Press Ctrl+C to stop."
sleep infinity
