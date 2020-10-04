#region Troubleshooting

# Check HTTP status codes
# Install cURL
choco install -y curl

# Show all curl options/switches
curl -h

# Common options
-I, --head          Show document info only
-i, --include       Include protocol response headers in the output
-k, --insecure      Allow insecure server connections when using SSL
-L, --location      Follow redirects
-s, --silent        Silent mode
-v, --verbose       Make the operation more talkative

# Test ingress
# Set domain
$nexusHost = kubectl get ingress -A -o jsonpath="{.items[0].spec.rules[1].host}"
$nexusBaseUrl = "https://$nexusHost"

# curl -kivL -H 'Host: <HostUsedWithinIngressConfig>' 'http://<LoadBalancerExternalIp>'
curl -kivL -H 'Host: $nexusBaseUrl' 'http://51.140.114.66'

# Should return "200" if Default backend is running ok
curl -I $nexusBaseUrl/healthz

# Should return "200", maybe "404" if configured wrong
curl -I $nexusBaseUrl/helloworld

# Show HTML output
curl $nexusBaseUrl/helloworld
curl $nexusBaseUrl

# Misc
curl -I $nexusBaseUrl/helloworld
curl -I $nexusBaseUrl
# Ignore cert errors
curl -i -k $nexusBaseUrl/helloworld
curl -i -k $nexusBaseUrl

# Check SSL
# Use www.ssllabs.com for thorough SSL cert check
"https://www.ssllabs.com/ssltest/analyze.html?d=$nexusBaseUrl"

# openssl s_client
# to prevent hanging, use "echo Q | " at the start
# openssl s_client -connect host:port -status [-showcerts]
echo Q | openssl s_client -connect docker.thehypepipe.co.uk:443 | sls "CN =|error"
echo Q | openssl s_client -connect "$($nexusHost):443" | sls "CN =|error"
echo Q | openssl s_client -connect "$($nexusHost):443" -status -showcerts
echo Q | openssl s_client -connect "$($nexusHost):443" -status

# ! COMMON ISSUES
# - default-backend-service will show when ingress not configured correctly or it does not have endpoints
# - ensure the ingress namespace matches the service namespaces

# * IMPORTANT
# permanently save the namespace for all subsequent kubectl commands in that context
kubectl config set-context --current --namespace=ingress

# Check the Ingress Resource Events
kubectl get events -A --watch
$ingressControllerPodName = kubectl get pod -l component=controller -o jsonpath="{.items[0].metadata.name}"
kubectl get ing
kubectl get ing ingress -o yaml
kubectl describe ing ingress
kubectl describe ing ingress-static
kubectl get svc nginx-ingress-controller
kubectl describe pod $ingressControllerPodName

# Check the Ingress Controller Logs
kubectl logs -f -l component=controller --all-containers=true

# Check the NginX Configuration
# NginX vscode extension: https://marketplace.visualstudio.com/items?itemName=raynigon.nginx-formatter
# Search nginx.conf for location {} blocks, including "$service_name" etc
# Ensure $namespace, $ingress_name, $service_name, and $service_port are correct
kubectl get pods
kubectl exec -it $ingressControllerPodName cat /etc/nginx/nginx.conf > nginx.conf

# Check Stats within Controller pod
kubectl exec -it $ingressControllerPodName /bin/bash
curl http://localhost/nginx_status

# Check if used Services Exist
kubectl get svc --all-namespaces

# Check default backend pod
kubectl describe pods -l component=default-backend


# Debug Logging
# Using the flag --v=XX it is possible to increase the level of logging.
# This is performed by editing the deployment
kubectl get deploy

# Instruct kubectl to edit using vscode
$env:KUBE_EDITOR = 'code --wait'
kubectl edit deploy nginx-ingress-controller

# Add --v=X to "- args", where X is an integer
--v=2 shows details using diff about the changes in the configuration in nginx
--v=3 shows details about the service, Ingress rule, endpoint changes and it dumps the nginx configuration in JSON format
--v=5 configures NGINX in debug mode



# Debugging cert-manager
# Show all resource types
kubectl api-resources
kubectl api-resources | sls "cert-manager.io"

# Show cert-manager resources
kubectl get challenges,orders,certificaterequests,certificates,clusterissuers,issuers -A
kubectl get challenges -A -o wide
kubectl get orders -A -o wide
kubectl get certificaterequests -A -o wide
kubectl get certificates -A -o wide
kubectl get clusterissuers -A -o wide
kubectl get issuers -A -o wide

# Check Custom Resource Definitions
kubectl get crd

# Show cert-manager pods
kubectl get pods -l app.kubernetes.io/instance=cert-manager -o wide

# Check pod status and events
$certManagerPod = kubectl get pod -l app.kubernetes.io/name=cert-manager -o jsonpath="{.items[0].metadata.name}"
$caInjectorPod = kubectl get pod -l app.kubernetes.io/name=cainjector -o jsonpath="{.items[0].metadata.name}"
$webhookPod = kubectl get pod -l app.kubernetes.io/name=webhook -o jsonpath="{.items[0].metadata.name}"
kubectl describe pods $certManagerPod
kubectl describe pods $caInjectorPod
kubectl describe pods $webhookPod

# Check pod status and events
# kubectl logs -f -l LABEL=VALUE --all-containers=true
kubectl logs -f $certManagerPod --all-containers=true
kubectl logs -f $caInjectorPod --all-containers=true
kubectl logs -f $webhookPod --all-containers=true

# Check DNS from within pods
kubectl exec -it $certManagerPod cert-manager sh
kubectl exec -it $caInjectorPod sh
kubectl exec -it $webhookPod sh
# Check dns lookup
nslookup $nexusBaseUrl

# Main issue in initial build when running:
# "kubectl apply -f ./manifests/cluster-issuer.yml --namespace ingress"
[2020-02-22T12:58:13.628Z] Error from server (InternalError): error when creating "./manifests/cluster-issuer.yml": Internal error occurred: failed calling webhook "webhook.cert-manager.io": Post https://cert-manager-webhook.ingress.svc:443/mutate?timeout=30s: dial tcp 10.0.171.89:443: connect: connection refused

# Works second attempt
clusterissuer.cert-manager.io/letsencrypt configured

# Check cert issuer
# ClusterIssuer has cluster-wide scope
# Issuer has namespace scope
kubectl get ClusterIssuer -A
kubectl get Issuer -A

kubectl get customresourcedefinitions
kubectl get crd
kubectl get clusterissuers.cert-manager.io -A
kubectl get issuers.cert-manager.io -A

# Check webhook api
kubectl get apiservice v1beta1.webhook.certmanager.k8s.io
kubectl get apiservice | sls "webhook"


# Check ClusterIssuer is READY
# - Status > Conditions
# - Message: The ACME account was registered with the ACME server
kubectl get ClusterIssuer -A -o wide
kubectl describe ClusterIssuer letsencrypt-prod
kubectl describe ClusterIssuer letsencrypt-staging

# Check Certificate is READY
# - Status > Conditions
# - Message: Certificate is up to date and has not expired
kubectl get cert -A -o wide
kubectl describe cert tls-secret
kubectl get cert tls-secret --watch
kubectl delete cert tls-secret

# Check Secret
# Annotations should include multiple cert-manager.io entries
kubectl get secret tls-secret -o wide
kubectl describe secret tls-secret


# Recreate ingress
kubectl delete -f ./manifests/ingress.yml
kubectl apply -f ./manifests/ingress.yml

kubectl get ing -o wide
kubectl describe ingress
#endregion Troubleshooting
