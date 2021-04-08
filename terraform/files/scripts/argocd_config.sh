#!/bin/bash
#
# Argo CD configuration

# Ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Vars
ARGOCD_PATH="./argocd"
REPO_SSH_PRIVATE_KEY_PATH="./id_ed25519_argocd"
export ARGOCD_OPTS="--grpc-web"
ARGOCD_HEALTH_CHECK_URL="https://$ARGOCD_FQDN/healthz"

# Install
VERSION="v2.0.0"
curl -sSL -o "$ARGOCD_PATH" "https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64"
chmod +x "$ARGOCD_PATH"

# Wait for URL to be responsive
echo "Checking ArgoCD is ready on [$ARGOCD_HEALTH_CHECK_URL]..."
while [[ "$(curl -s -o /dev/null -w ''%{http_code}''  $ARGOCD_HEALTH_CHECK_URL)" != "200" ]]; do
    echo "Still waiting for ArgoCD to be ready on [$ARGOCD_HEALTH_CHECK_URL]..."
    sleep 10
done

# Show version
echo "Showing Argo CD version info for [$ARGOCD_FQDN]..."
"$ARGOCD_PATH" version --server "$ARGOCD_FQDN"

# Get default admin password
# default password is server pod name, eg: "argocd-server-89c6cd7d4-xxxxx"
echo "Getting default admin password..."
DEFAULT_ARGO_ADMIN_PASSWORD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)

# Login
echo "Logging in to Argo CD with default password..."
if "$ARGOCD_PATH" login "$ARGOCD_FQDN" --username admin --password "$DEFAULT_ARGO_ADMIN_PASSWORD"; then
    # Update default admin password
    echo "Updating default admin password..."
    "$ARGOCD_PATH" account update-password --account admin --current-password "$DEFAULT_ARGO_ADMIN_PASSWORD" --new-password "$ARGOCD_ADMIN_PASSWORD"
else
    echo "WARNING: Failed to log into Argo CD using default password..."
    echo "Attempting login with new admin password..."
    "$ARGOCD_PATH" login "$ARGOCD_FQDN" --username admin --password "$ARGOCD_ADMIN_PASSWORD"
fi

# Show info
echo "Showing Argo CD cluster info..."
"$ARGOCD_PATH" account list
"$ARGOCD_PATH" cluster list
"$ARGOCD_PATH" app list

# Add SSH repo connection
# Save repo private key
echo -e "$HELM_CHART_REPO_DEPLOY_PRIVATE_KEY" > "$REPO_SSH_PRIVATE_KEY_PATH"
chmod 600 "$REPO_SSH_PRIVATE_KEY_PATH"
echo "Showing public key fingerprint..."
ssh-keygen -lf "$REPO_SSH_PRIVATE_KEY_PATH"

# Add a Git repository via SSH using a private key for authentication
# [OPTIONAL] use "--insecure-ignore-host-key" during testing with self-signed certs
"$ARGOCD_PATH" repo add "$REPO_URL" --ssh-private-key-path "$REPO_SSH_PRIVATE_KEY_PATH"
