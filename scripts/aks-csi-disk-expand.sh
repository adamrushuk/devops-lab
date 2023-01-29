#!/usr/bin/env bash

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/pvc-azuredisk-csi.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/nginx-pod-azuredisk.yaml

# check disk size in pod
kubectl exec -it nginx-azuredisk -- df -h /mnt/azuredisk

    Filesystem                Size      Used Available Use% Mounted on
    /dev/sdd                  9.7G     36.0K      9.7G   0% /mnt/azuredisk

# ! this step ONLY required when using AKS v1.20 or below
# [optional] delete pod to unattach disk
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/nginx-pod-azuredisk.yaml



# Waits for an AKS disk to report "Unattached"

# vars
SUBSCRIPTION_NAME=""
AKS_CLUSTER_RESOURCEGROUP_NAME=""
AKS_CLUSTER_NAME=""
PVC_NAME="pvc-azuredisk"

# login
az login
az account set --subscription "$SUBSCRIPTION_NAME"

# get cluster and associated "node resource group" (where resources live)
DISK_RESOURCEGROUP_NAME=$(az aks show --name "$AKS_CLUSTER_NAME" --resource-group "$AKS_CLUSTER_RESOURCEGROUP_NAME" --query "nodeResourceGroup" --output tsv)

# define reusable function
get_disk_info() {
    az disk list --resource-group "$DISK_RESOURCEGROUP_NAME" --query "[?tags.\"kubernetes.io-created-for-pvc-name\" == '$PVC_NAME' ].{state:diskState, diskSizeGb:diskSizeGb, name:name, pvcname:tags.\"kubernetes.io-created-for-pvc-name\"}" --output table
}

# get disk associated with AKS PVC name
echo 'Waiting for disk to become "Unattached"...'
get_disk_info

# wait for disk state to detach
START_TIME=$SECONDS

while true; do
    # get disk info
    DISK_OUTPUT=$(get_disk_info)

    # check disk state
    if echo "$DISK_OUTPUT" | grep Attached; then
        sleep 10
    elif echo "$DISK_OUTPUT" | grep Unattached; then
        echo "Disk is now Unattached."
        break
    fi
done

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "Disk took [$(($ELAPSED_TIME / 60))m$(($ELAPSED_TIME % 60))s] to change states"

# final disk info
get_disk_info



# expand pvc
kubectl patch pvc pvc-azuredisk --type merge --patch '{"spec": {"resources": {"requests": {"storage": "15Gi"}}}}'

# create pod again
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/nginx-pod-azuredisk.yaml

# check disk size in pod
kubectl exec -it nginx-azuredisk -- df -h /mnt/azuredisk
