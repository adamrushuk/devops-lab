#!/bin/bash
# Pushes example Docker images to repo

docker pull busybox
docker pull nginxdemos/hello

docker image tag busybox "$DOCKER_FQDN/busybox"
docker image tag nginxdemos/hello "$DOCKER_FQDN/hello"

docker image ls "$DOCKER_FQDN/busybox"
docker image ls "$DOCKER_FQDN/hello"

docker push "$DOCKER_FQDN/busybox"
docker push "$DOCKER_FQDN/hello"
