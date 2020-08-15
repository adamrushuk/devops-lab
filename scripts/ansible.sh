#! /usr/bin/env bash
#
# Prepares env vars and runs Ansible Playbook

# Ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Init
# Get AKS Cluster credentials
message="Merging AKS credentials"
echo "STARTED: $message..."
az aks get-credentials --resource-group "$AKS_RG_NAME" --name "$AKS_CLUSTER_NAME" --overwrite-existing --admin
echo "FINISHED: $message."

# Set environment variables for passwords
export NEW_ADMIN_PASSWORD=$NEXUS_ADMIN_PASSWORD
echo "FINISHED: $message."

# Set base url
protocol="http"
if [ "$ENABLE_TLS_INGRESS" == "true" ]; then
    protocol="https"
fi
nexusBaseUrl="$protocol://$DNS_DOMAIN_NAME"

# Run Ansible Playbook
message="Running Ansible playbook"
echo "STARTED: $message..."
pushd ansible
ansible-playbook site.yml --extra-vars "api_base_uri=$nexusBaseUrl"
popd
echo "FINISHED: $message."
