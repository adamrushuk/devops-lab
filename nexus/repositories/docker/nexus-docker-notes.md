# Nexus Docker Repository Notes

## Contents

- [Nexus Docker Repository Notes](#nexus-docker-repository-notes)
  - [Contents](#contents)
  - [Prereqs](#prereqs)
  - [Configure Docker Repo](#configure-docker-repo)
  - [Configure Docker Client (if using insecure HTTP Ingress)](#configure-docker-client-if-using-insecure-http-ingress)
  - [Login to Docker Repo](#login-to-docker-repo)
  - [Push Images to Docker Repo](#push-images-to-docker-repo)
  - [Search Docker Repo](#search-docker-repo)
  - [Pull Image from Docker Repo](#pull-image-from-docker-repo)
  - [Using an Image from Nexus Docker Repo](#using-an-image-from-nexus-docker-repo)

## Prereqs

Follow the [Login to Nexus Console](./../../../README.md#login-to-nexus-console) steps in the main README.

## Configure Docker Repo

1. Set variables:

    ```powershell
    # Set Nexus Docker vars
    $nexusDockerHost = kubectl get ingress -A -o jsonpath="{.items[0].spec.rules[1].host}"
    $nexusDockerBaseUrl = "https://$nexusDockerHost"
    ```

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
    Invoke-RestMethod $nexusDockerBaseUrl
    ```

## Configure Docker Client (if using insecure HTTP Ingress)

**NOTE:** This section is not required when using valid TLS certs (HTTPS Ingress)

1. Open `~/.docker/daemon.json` or if using **docker-machine**, open `~/.docker/machine/machines/default/config.json`

    ```powershell
    # Standard config
    code "$HOME/.docker/daemon.json"

    # docker-machine client
    code "$HOME/.docker/machine/machines/default/config.json"


    # [OPTIONAL] docker-machine VM steps below
    docker-machine start

    # Login to docker-machine
    docker-machine ssh

    # Add config
    vi /etc/docker/daemon.json

    # Restart daemon
    sudo /etc/init.d/docker restart
    ```

1. Enter the docker ingress FQDN to `insecure-registries`, eg:

    ```json
    {
      "insecure-registries": [ "docker-nexus.domain.com" ]
    }
    ```

1. Restart docker daemon:

    ```powershell
    # Standard
    sudo systemctl restart docker


    # Load env vars for docker cli
    # may need to wait a minute after starting docker-machine vm
    & docker-machine env --shell powershell default | Invoke-Expression
    $env:DOCKER_TLS_VERIFY = 0
    gci env:DOCKER*
    ```

1. Confirm the Nexus Docker repo is listed with `Secure=False`:

    ```powershell
    $dockerSysInfoJson = docker system info --format '{{json .}}' | ConvertFrom-Json
    $dockerSysInfoJson.RegistryConfig.IndexConfigs

    http://docker-nexus.domain.com
    ------------------------------
    @{Name=docker-nexus.domain.com; Mirrors=System.Object[]; Secure=False; Official=False}
    ```

## Login to Docker Repo

Login to the Nexus Docker repo (adds an entry to `~/.docker/config.json`):

```powershell
# check build.yml for DEMO_USER vars
$demoUserUsername = <DEMO_USER_USERNAME>
$demoUserPassword = <DEMO_USER_PASSWORD>
# Input password via STDIN
echo $demoUserPassword | docker login --username $demoUserUsername --password-stdin $nexusDockerBaseUrl
```

## Push Images to Docker Repo

1. First, pull example images for testing:

    ```powershell
    # these are lightweight images; great for testing
    docker pull busybox
    docker pull nginxdemos/hello
    ```

1. Tag the images with Nexus repo name:

    ```powershell
    # docker image tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
    docker image tag busybox $nexusDockerHost/busybox
    docker image tag nginxdemos/hello $nexusDockerHost/hello
    ```

1. List the tagged images:

    ```powershell
    # docker image ls [OPTIONS] [REPOSITORY[:TAG]]
    docker image ls $nexusDockerHost/busybox
    docker image ls $nexusDockerHost/hello
    ```

1. Push the images:

    ```powershell
    # docker image push [OPTIONS] NAME[:TAG]
    docker push $nexusDockerHost/busybox
    docker push $nexusDockerHost/hello
    ```

## Search Docker Repo

Search via the API:

```powershell
# List repositories
Invoke-RestMethod $nexusDockerBaseUrl/v2/_catalog

# List tags
Invoke-RestMethod $nexusDockerBaseUrl/v2/busybox/tags/list
Invoke-RestMethod $nexusDockerBaseUrl/v2/hello/tags/list
```

## Pull Image from Docker Repo

1. First, delete the local image copies:

    ```powershell
    # images currently exist
    docker image ls $nexusDockerHost/busybox
    docker image ls $nexusDockerHost/hello

    # docker image rm [OPTIONS] IMAGE [IMAGE...]
    docker image rm $nexusDockerHost/busybox
    docker image rm $nexusDockerHost/hello
    ```

1. Show images have been deleted:

    ```powershell
    # docker image ls [OPTIONS] [REPOSITORY[:TAG]]
    docker image ls $nexusDockerHost/busybox
    docker image ls $nexusDockerHost/hello
    ```

1. Pull images from Nexus Docker repo:

    ```powershell
    # docker image pull [OPTIONS] NAME[:TAG|@DIGEST]
    docker image pull $nexusDockerHost/busybox
    docker image pull $nexusDockerHost/hello
    ```

1. Show images are locally available again:

    ```powershell
    # docker image ls [OPTIONS] [REPOSITORY[:TAG]]
    docker image ls $nexusDockerHost/busybox
    docker image ls $nexusDockerHost/hello
    ```

## Using an Image from Nexus Docker Repo

1. Add secret:

    ```powershell
    # Add secret
    # https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line
    kubectl create secret docker-registry regcred `
    --namespace ingress `
    --docker-server=$nexusDockerHost `
    --docker-username=$demoUserUsername `
    --docker-password=$demoUserPassword

    # [OPTIONAL] Add secret using existing Docker config `~/.docker/config.json`
    # WARNING: credential helpers (credHelpers or credsStore) are not supported
    # https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#registry-secret-existing-credentials
    kubectl create secret generic nexus-docker-credentials `
        --namespace ingress `
        --from-file=.dockerconfigjson="~/.docker/config.json" `
        --type=kubernetes.io/dockerconfigjson

    # Show secret
    kubectl get secret regcred --namespace ingress --output yaml

    # Inspect secret data
    # bash
    kubectl get secret regcred --namespace ingress --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode

    # powershell
    $base64String = kubectl get secret regcred --namespace ingress --output="jsonpath={.data.\.dockerconfigjson}"
    [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($base64String))

    # WIP: can we pipe to WSL?
    kubectl get secret regcred --namespace ingress --output="jsonpath={.data.\.dockerconfigjson}" | wsl.exe base64 --decode
    kubectl get secret regcred --namespace ingress --output="jsonpath={.data.\.dockerconfigjson}" | wsl.exe base64 --decode "$_"
    ```

1. Apply kubernetes manifest:

    ```powershell
    # Replace token
    $env:DNS_DOMAIN_NAME = $nexusHost
    ./scripts/Replace-Tokens.ps1 -TargetFilePattern "./nexus/repositories/docker/docker-manifest.yml"

    # Apply
    kubectl apply -f ./nexus/repositories/docker/docker-manifest.yml
    ```

1. Test deployment:

    ```powershell
    # Check resources
    kubectl get all,ing --namespace ingress -l app=hello
    kubectl describe deploy --namespace ingress -l app=hello

    # Show all pods not running
    kubectl get pods --field-selector=status.phase!=Running --all-namespaces

    # Show events
    kubectl get events --sort-by=.metadata.creationTimestamp --namespace ingress

    # Test web output
    $testUrl = "$nexusBaseUrl/hello"
    curl $testUrl
    curl -ivk $testUrl

    # Open website
    Start-Process $testUrl
    ```

1. [OPTIONAL] Troubleshoot:

    ```powershell
    # Enter pod shell
    $podName = kubectl get pod -n ingress -l app=hello -o jsonpath="{.items[0].metadata.name}"
    kubectl exec -n ingress -it $podName /bin/sh

    # Show open ports (eg 80, 443)
    netstat -tulpn

    # Install utils (as container image uses lightweight Alpine distro)
    apk add --update curl lynx htop
    apk info | sort

    # Get website content only
    lynx -dump http://localhost/hello

    # Get website html
    curl http://localhost/hello

    # Get website headers and html
    curl -ivk http://localhost/hello
    ```
