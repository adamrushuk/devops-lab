#!/bin/bash
#
# Argo CD configuration

# Ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Vars
ARGOCD_PATH="./argocd"
REPO_SSH_PRIVATE_KEY_PATH="./id_ed25519_argocd"

# Install
VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
curl -SL -o "$ARGOCD_PATH" "https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64"
chmod +x "$ARGOCD_PATH"

# Show version
echo "Showing Argo CD version info..."
"$ARGOCD_PATH" version --grpc-web --server "$ARGOCD_FQDN"

# Get default admin password
# default password is server pod name, eg: "argocd-server-89c6cd7d4-xxxxx"
echo "Getting default admin password..."
DEFAULT_ARGO_ADMIN_PASSWORD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)

# Login
echo "Logging in to Argo CD..."
"$ARGOCD_PATH" login "$ARGOCD_FQDN" --grpc-web --username admin --password "$DEFAULT_ARGO_ADMIN_PASSWORD"

# Update admin password
echo "Updating default admin password..."
"$ARGOCD_PATH" account update-password --grpc-web --account admin --current-password "$DEFAULT_ARGO_ADMIN_PASSWORD" --new-password "$ARGOCD_ADMIN_PASSWORD"

# Show info
echo "Showing Argo CD cluster info..."
"$ARGOCD_PATH" account list
"$ARGOCD_PATH" cluster list
"$ARGOCD_PATH" app list

# Add SSH repo connection
# Save repo private key
echo "$HELM_CHART_REPO_DEPLOY_PRIVATE_KEY" > "$REPO_SSH_PRIVATE_KEY_PATH"

# ! TODO: Temp debugging, remove and change key once fixed
echo "TEMP DEBUGGING...REMOVE AFTERWARDS!!!!..."
echo "echo HELM_CHART_REPO_DEPLOY_PRIVATE_KEY..."
echo "$HELM_CHART_REPO_DEPLOY_PRIVATE_KEY"
echo "cat REPO_SSH_PRIVATE_KEY_PATH..."
cat "$REPO_SSH_PRIVATE_KEY_PATH"

# Add a Git repository via SSH using a private key for authentication
# [OPTIONAL] use "--insecure-ignore-host-key" during testing with self-signed certs
"$ARGOCD_PATH" repo add "$REPO_URL" --ssh-private-key-path "$REPO_SSH_PRIVATE_KEY_PATH"
