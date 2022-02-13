kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/pvc-azuredisk-csi.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/nginx-pod-azuredisk.yaml

# check disk size in pod
kubectl exec -it nginx-azuredisk -- df -h /mnt/azuredisk

    Filesystem                Size      Used Available Use% Mounted on
    /dev/sdd                  9.7G     36.0K      9.7G   0% /mnt/azuredisk

# delete pod top unattach disk
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/nginx-pod-azuredisk.yaml



# TODO: add code that waits for disk state to be "unattached"
# where tag is: "kubernetes.io-created-for-pvc-name": "pvc-azuredisk"
PVC_NAME='pvc-azuredisk'
while true; do
    # body
    az disk list --query "[?tags.\"kubernetes.io-created-for-pvc-name\" == '$PVC_NAME'].{state:diskState, diskSizeGb:diskSizeGb, name:name, pvcname:tags.\"kubernetes.io-created-for-pvc-name\"}" -o table
    echo
    sleep 2
done



# expand pvc
kubectl patch pvc pvc-azuredisk --type merge --patch '{"spec": {"resources": {"requests": {"storage": "15Gi"}}}}'

# create pod again
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/nginx-pod-azuredisk.yaml

# check disk size in pod
kubectl exec -it nginx-azuredisk -- df -h /mnt/azuredisk



