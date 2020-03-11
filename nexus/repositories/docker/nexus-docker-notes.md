# Nexus Docker Repository Notes

## Contents

- [Nexus Docker Repository Notes](#nexus-docker-repository-notes)
  - [Contents](#contents)
  - [Prereqs](#prereqs)
  - [Configure Docker Repo](#configure-docker-repo)
  - [Configure Docker Client](#configure-docker-client)
  - [Login to Nexus Docker Repo](#login-to-nexus-docker-repo)
  - [WIP](#wip)
- [search](#search)

## Prereqs

Follow the [Login to Nexus Console](./../../../README.md#login-to-nexus-console) steps in the main README.

## Configure Docker Repo

1. Move `Docker Bearer Token Realm` into `Active`:

    ```powershell
    # Open Nexus console make Realm changes
    Start-Process "$nexusBaseUrl/#admin/security/realms"
    ```

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

## Configure Docker Client

1. Open `~/.docker/daemon.json`.
1. Enter the docker ingress FQDN to `insecure-registries`:

    ```json
    {
      "insecure-registries" : [ "docker-nexus.thehypepipe.co.uk" ]
    }
    ```

1. Restart docker daemon.

## Login to Nexus Docker Repo

1. Open `~/.docker/daemon.json`.

    ```powershell
    # Open Nexus console
    echo $adminPassword | docker login --username admin --password-stdin http://docker-nexus.thehypepipe.co.uk
    ```

########

## WIP
docker-repo
port 8123
create repo

iwr docker-nexus.thehypepipe.co.uk

update ~/.docker/daemon.json and restart docker 
  "insecure-registries": [
    "docker-nexus.thehypepipe.co.uk"
  ],
  
login

cat ~/my_password.txt | docker login --username foo --password-stdin

<!-- docker login -u admin -p admin123 nexus-docker.minikube -->
docker login -u admin -p <PASSWORD> docker-nexus.thehypepipe.co.uk
docker login docker-nexus.thehypepipe.co.uk

docker system info

cat ~/.docker/config.json
cat /etc/docker/daemon.json

cat C:\ProgramData\docker\config\daemon.json

docker pull busybox
docker image tag busybox docker-nexus.thehypepipe.co.uk/busybox
docker image ls docker-nexus.thehypepipe.co.uk/busybox
docker push docker-nexus.thehypepipe.co.uk/busybox

# search

Connect registry in vscode Docker Extension

curl -X GET http://docker-nexus.thehypepipe.co.uk/v2/_catalog
irm http://docker-nexus.thehypepipe.co.uk/v2/_catalog
irm http://docker-nexus.thehypepipe.co.uk/v2/busybox/tags/list
