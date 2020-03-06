# Helm v2 initialisation
# https://v2.helm.sh/docs/rbac/#example-service-account-with-cluster-admin-role

# helm init --wait
# kubectl create sa -n kube-system tiller
# kubectl create clusterrolebinding tiller-cluster-admin --clusterrole cluster-admin --serviceaccount kube-system:tiller
# helm init --service-account=tiller --wait --upgrade

# Helm RBAC
Write-Output "`nAPPLYING: Helm manifest for Tiller RBAC..."
kubectl apply -f ./manifests/rbac-config.yml
helm init --service-account tiller --history-max 200 --upgrade --wait --debug
# --tiller-tls

helm version
