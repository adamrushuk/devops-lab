# Nexus Docker Repository Notes

## Contents

- [Nexus Docker Repository Notes](#nexus-docker-repository-notes)
  - [Contents](#contents)
  - [Prereqs](#prereqs)
  - [Configure Docker Repo](#configure-docker-repo)
  - [Configure Docker Client](#configure-docker-client)
  - [Login to Docker Repo](#login-to-docker-repo)
  - [Push Image to Docker Repo](#push-image-to-docker-repo)
  - [Search Docker Repo](#search-docker-repo)
  - [Pull Image from Docker Repo](#pull-image-from-docker-repo)

## Prereqs

Follow the [Login to Nexus Console](./../../../README.md#login-to-nexus-console) steps in the main README.

## Configure Docker Repo

1. Move `Docker Bearer Token Realm` into `Active`:

    ```powershell
    # Open Nexus console make Realm changes
    Start-Process "$nexusBaseUrl/#admin/security/realms"
    ```

1. Click `Save`.
1. Navigate to Repositories admin page:

    ```powershell
    # Open Nexus console
    Start-Process "$nexusBaseUrl/#admin/repository/repositories"
    ```

1. Click `Create repository`.
1. Select `docker (hosted)` recipe.
1. Enter repo name: `docker-repo`
1. Tick `http` Repository Connector and enter port: `8123`
1. Tick `Allow anonymous docker pull`.
1. Leave the rest of the settings as default, and click `Create repository` at the bottom.
1. When configured correctly, the following command should return the `Error 400 Not a Docker request`:

    ```powershell
    # "HTTP ERROR 400" error is expected
    Invoke-RestMethod docker-nexus.thehypepipe.co.uk
    ```

## Configure Docker Client

1. Open `~/.docker/daemon.json`.
1. Enter the docker ingress FQDN to `insecure-registries`:

    ```json
    {
      "insecure-registries": [ "docker-nexus.thehypepipe.co.uk" ]
    }
    ```

1. Restart docker daemon.
1. Confirm the Nexus Docker repo is listed with `Secure=False`:

    ```powershell
    $dockerSysInfoJson = docker system info --format '{{json .}}' | ConvertFrom-Json
    $dockerSysInfoJson.RegistryConfig.IndexConfigs

    docker-nexus.thehypepipe.co.uk
    ------------------------------
    @{Name=docker-nexus.thehypepipe.co.uk; Mirrors=System.Object[]; Secure=False; Official=False}
    ```

## Login to Docker Repo

```powershell
# Input password via STDIN
echo $adminPassword | docker login --username admin --password-stdin http://docker-nexus.thehypepipe.co.uk
```

## Push Image to Docker Repo

1. First, pull an example image for testing:

    ```powershell
    # busybox is very lightweight; great for testing
    docker pull busybox
    ```

1. Tag the busybox image with Nexus repo name:

    ```powershell
    # docker image tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
    docker image tag busybox docker-nexus.thehypepipe.co.uk/busybox
    ```

1. List the tagged image:

    ```powershell
    # docker image ls [OPTIONS] [REPOSITORY[:TAG]]
    docker image ls docker-nexus.thehypepipe.co.uk/busybox
    ```

1. Push the image:

    ```powershell
    # docker image push [OPTIONS] NAME[:TAG]
    docker push docker-nexus.thehypepipe.co.uk/busybox
    ```

## Search Docker Repo

Search via the API:

```powershell
# List repositories
Invoke-RestMethod http://docker-nexus.thehypepipe.co.uk/v2/_catalog

# List tags
Invoke-RestMethod http://docker-nexus.thehypepipe.co.uk/v2/busybox/tags/list
```

## Pull Image from Docker Repo

1. First, delete the local copy of the busybox image:

    ```powershell
    # image currently exists
    docker image ls docker-nexus.thehypepipe.co.uk/busybox

    # docker image rm [OPTIONS] IMAGE [IMAGE...]
    docker image rm docker-nexus.thehypepipe.co.uk/busybox
    ```

1. Show image has been deleted:

    ```powershell
    # docker image ls [OPTIONS] [REPOSITORY[:TAG]]
    docker image ls docker-nexus.thehypepipe.co.uk/busybox
    ```

1. Pull image from Nexus Docker repo:

    ```powershell
    # docker image pull [OPTIONS] NAME[:TAG|@DIGEST]
    docker image pull docker-nexus.thehypepipe.co.uk/busybox
    ```

1. Show image is locally available again:

    ```powershell
    # docker image ls [OPTIONS] [REPOSITORY[:TAG]]
    docker image ls docker-nexus.thehypepipe.co.uk/busybox
    ```
