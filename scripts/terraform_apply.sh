#!/bin/bash
# Runs Terraform apply

# Ensure strict mode and predictable pipeline failure
set -euo pipefail

# Change into TF folder location
pushd ./terraform

# Apply terraform
message="Applying Terraform configuration"
echo "STARTED: $message..."
terraform apply -auto-approve
echo "FINISHED: $message."

# Revert to previous folder location
popd
