#!/usr/bin/env bash
# Model provisioning service

function run_provisioning() {
    # Check if external provisioning is enabled
    if [[ -z "${PROVISION_URL}" ]]; then
        echo "provisioning: PROVISION_URL not set, skipping external model provisioning"
        echo "provisioning: Upload models and datasets via File Manager (port 7010)"
        return
    fi

    echo "provisioning: starting external model provisioning"
    echo "provisioning: config URL: ${PROVISION_URL}"

    # Create provisioning directory
    mkdir -p ${WORKSPACE}/logs

    # Run external provisioning script
    echo "provisioning: downloading external models..."
    if /opt/provision/provision.py "${PROVISION_URL}"; then
        echo "provisioning: external provisioning completed successfully"
    else
        echo "provisioning: external provisioning failed, but continuing startup"
        echo "provisioning: check ${WORKSPACE}/logs/provision.log for details"
    fi
}

# Note: Function is called explicitly from start.sh
# No auto-execution when sourced to prevent duplicate processes