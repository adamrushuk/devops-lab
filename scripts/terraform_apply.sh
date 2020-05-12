#! /usr/bin/env bash
# Runs Terraform apply

# ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Change into TF folder location
pushd ./terraform

# Apply terraform
message="Applying Terraform configuration"
echo "STARTED: $message..."
terraform apply -auto-approve "$TF_PLAN"
echo "FINISHED: $message."

# Revert to previous folder location
popd
