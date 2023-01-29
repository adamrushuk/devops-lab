#! /usr/bin/env bash
# Pushes example Docker images to repo

# Ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# vars
# DOCKER_FQDN='docker.thehypepipe.co.uk'
DOCKER_SERVER="https://$DOCKER_FQDN"

# Check if images already exist
main_message="Pushing docker image tasks"
echo -e "\nSTARTED: $main_message..."

# List repositories
repos=$(curl -s "$DOCKER_SERVER/v2/_catalog" | jq ".repositories")

if [[ "$repos" == "[]" ]]; then
    message="Pulling base images..."
    echo -e "\nSTARTED: $message..."
    docker pull busybox
    docker pull nginxdemos/hello
    echo -e "\nFINISHED: $message."

    message="Tagging images..."
    docker image tag busybox "$DOCKER_FQDN/busybox"
    docker image tag nginxdemos/hello "$DOCKER_FQDN/hello"
    echo -e "\nFINISHED: $message."

    message="Listing images..."
    docker image ls "$DOCKER_FQDN/busybox"
    docker image ls "$DOCKER_FQDN/hello"
    echo -e "\nFINISHED: $message."

    message="Pushing images..."
    docker push "$DOCKER_FQDN/busybox"
    docker push "$DOCKER_FQDN/hello"
    echo -e "\nFINISHED: $message."

    echo -e "\nFINISHED: $main_message."
else
    echo -e "\nSKIPPING: $main_message...they already exist in repo."

    # List tags
    curl -s "$DOCKER_SERVER/v2/busybox/tags/list"
    curl -s "$DOCKER_SERVER/v2/hello/tags/list"
fi
