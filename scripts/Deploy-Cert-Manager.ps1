# Deploy cert-manager

# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

#region cert-manager
# https://cert-manager.io/docs/installation/kubernetes/#installing-with-helm
$message = "[HELM] Installing cert-manager"
Write-Output "STARTED: $message..."
# Install the CustomResourceDefinition resources separately
# kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/v0.13.1/deploy/manifests/00-crds.yaml --namespace ingress-tls
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/v0.13.1/deploy/manifests/00-crds.yaml

# Label the ingress-tls namespace to disable resource validation
# kubectl label namespace ingress-tls certmanager.k8s.io/disable-validation=true

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
# https://hub.helm.sh/charts/jetstack/cert-manager

# Check if Helm release installed already
$helmReleaseName = "cert-manager"
$helmDeployedList = helm list --namespace ingress-tls --output json | ConvertFrom-Json

if ($helmReleaseName -in $helmDeployedList.Releases.Name) {
    Write-Output "SKIPPING: [$helmReleaseName] already deployed."
} else {
    Write-Output "STARTED: Installing helm release: [$helmReleaseName]..."

    # helm upgrade [RELEASE] [CHART] [flags]
    # helm upgrade something ./path/to/my/chart -f my-values.yaml --install --atomic
    # helm upgrade `
    #     cert-manager jetstack/cert-manager `
    #     --install --atomic `
    #     --namespace ingress-tls `
    #     --version v0.13.1

    # [OPTIONAL] args
    # --set ingressShim.defaultIssuerName=letsencrypt `
    # --set ingressShim.defaultIssuerKind=ClusterIssuer `
    # --set extraArgs={"--dns01-recursive-nameservers=8.8.8.8:53,8.8.4.4:53"}


    # https://github.com/jetstack/cert-manager/blob/master/deploy/charts/cert-manager/values.yaml
    # helm upgrade [RELEASE] [CHART] [flags]
    helm upgrade cert-manager jetstack/cert-manager `
        --namespace ingress-tls `
        --install --atomic `
        -f ./cert-manager/certmanager_values.yaml `
        --version v0.13.1
        # --debug --dry-run

}

# Verify
# Show cert-manager pods
kubectl get pods -l app.kubernetes.io/instance=cert-manager -o wide --namespace ingress-tls

Write-Output "FINISHED: $message.`n"
#endregion
