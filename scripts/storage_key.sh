#! /usr/bin/env bash
#
# Get Storage Account key and update GitHub Workflow

# ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Storage Account Key
taskMessage="Getting Storage Account Key"
echo "STARTED: $taskMessage..."
storage_key=$(az storage account keys list --resource-group "$TERRAFORM_STORAGE_RG" --account-name "$TERRAFORM_STORAGE_ACCOUNT" --query [0].value -o tsv)
echo "FINISHED: $taskMessage."


# Set env vars
taskMessage="Updating workflow env vars"
echo "STARTED: $taskMessage..."

# # https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-commands-for-github-actions#environment-files
# echo "{name}={value}" >> $GITHUB_ENV
echo "STORAGE_KEY=$storage_key" >> "$GITHUB_ENV"

# Mask sensitive env var
# https://help.github.com/en/actions/reference/development-tools-for-github-actions#example-masking-an-environment-variable
STORAGE_KEY=$storage_key
echo "::add-mask::$STORAGE_KEY"

# also mask token format
__STORAGE_KEY__=$storage_key
echo "::add-mask::$__STORAGE_KEY__"

echo "FINISHED: $taskMessage."
