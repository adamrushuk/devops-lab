# Nexus Docker Repository Notes

## Contents

- [Nexus Docker Repository Notes](#nexus-docker-repository-notes)
  - [Contents](#contents)
  - [Prereqs](#prereqs)
  - [WIP](#wip)
- [search](#search)

## Prereqs

1. Import the AKS Cluster credentials:
    ```powershell
    # Vars
    $prefix = "rush"
    $aksClusterName = "$($prefix)-aks-001"
    $aksClusterResourceGroupName = "$($prefix)-rg-aks-dev-001"

    # AKS Cluster credentials
    az aks get-credentials --resource-group $aksClusterResourceGroupName --name $aksClusterName --overwrite-existing

    # [OPTIONAL] View AKS Dashboard
    az aks browse --resource-group $aksClusterResourceGroupName --name $aksClusterName
    ```
1. Get the auto-generated admin password from within the Nexus container:
    ```powershell
    # Get pod name
    $podName = kubectl get pod -n ingress-tls -l app=nexus -o jsonpath="{.items[0].metadata.name}"
    
    # Connect to pod
    kubectl exec -n ingress-tls -it $podName /bin/bash
    
    # Output admin password
    echo -e "\nadmin password: \n$(cat /nexus-data/admin.password)\n"
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
<!-- docker login -u admin -p admin123 nexus-docker.minikube -->
docker login -u admin -p <PASSWORD> docker-nexus.thehypepipe.co.uk

cat ~/.docker/config.json

docker ps

docker pull busybox
docker image ls
docker image tag busybox docker-nexus.thehypepipe.co.uk/busybox
docker push docker-nexus.thehypepipe.co.uk/busybox

docker ps

# search

Connect registry in vscode Docker Extension

curl -X GET http://docker-nexus.thehypepipe.co.uk/v2/_catalog
irm http://docker-nexus.thehypepipe.co.uk/v2/_catalog
irm http://docker-nexus.thehypepipe.co.uk/v2/busybox/tags/list
