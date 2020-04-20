#!/bin/bash
# Pushes example Docker images to repo

# Ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Check if images already exist
message="Pushing docker images"
echo -e "\nSTARTED: $message..."

# List repositories
repos=$(curl -s "$DOCKER_FQDN/v2/_catalog" | jq ".repositories")

if [[ "$repos" == "[]" ]]; then
    docker pull busybox
    docker pull nginxdemos/hello

    docker image tag busybox "$DOCKER_FQDN/busybox"
    docker image tag nginxdemos/hello "$DOCKER_FQDN/hello"

    docker image ls "$DOCKER_FQDN/busybox"
    docker image ls "$DOCKER_FQDN/hello"

    docker push "$DOCKER_FQDN/busybox"
    docker push "$DOCKER_FQDN/hello"

    echo -e "\nFINISHED: $message."
else
    echo -e "\nSKIPPING: $message...they already exist in repo."

    # List tags
    curl -s "$DOCKER_FQDN/v2/busybox/tags/list"
    curl -s "$DOCKER_FQDN/v2/hello/tags/list"
fi
