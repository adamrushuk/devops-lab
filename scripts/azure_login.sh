#!/bin/bash
#
# login to azure using azure service principal env vars

# ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

taskMessage="Logging in to Azure"
echo "STARTED: $taskMessage..."
az login --service-principal --tenant "$ARM_TENANT_ID" -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET"
echo "FINISHED: $taskMessage."

taskMessage="Selecting Subscription"
echo "STARTED: $taskMessage..."
az account set --subscription "$ARM_SUBSCRIPTION_ID"
echo "FINISHED: $taskMessage."
