# Ingress Troubleshooting Notes

- [Ingress Troubleshooting Notes](#ingress-troubleshooting-notes)
  - [Scenario](#scenario)
  - [Standard Ingress Troubleshooting](#standard-ingress-troubleshooting)
  - [NGINX Ingress Troubleshooting](#nginx-ingress-troubleshooting)
  - [Reference](#reference)

## Scenario

Our example Ingress called `hello` is showing a `503` error when browsing to `http://nexus.thehypepipe.co.uk/hello`.

## Standard Ingress Troubleshooting

```powershell
# Test web output
curl -v http://nexus.thehypepipe.co.uk/hello
curl -v https://nexus.thehypepipe.co.uk/hello
curl -ivk https://nexus.thehypepipe.co.uk/hello

# List ingress
kubectl get ing -A


# INGRESS
# check:
# - backend service IP/port, and the endpoint IP/port in brackets
# - endpoints DONT show as <none>
kubectl describe ing ingress --namespace ingress-tls
kubectl describe ing hello --namespace ingress-tls


# SERVICE
# check:
# - endpoints exist (these are pod IPs)
# - Selector criteria
kubectl describe service nexus --namespace ingress-tls
kubectl describe service hello --namespace ingress-tls
kubectl describe service hello


# POD
# check:
# - Ready condition
# - IP matches service endpoint
kubectl get pod --namespace ingress-tls -l app=hello -o wide

# check:
# - labels match for service selector criteria
# - exposed ports match between service and pod
# - Events for errors
kubectl describe pod --namespace ingress-tls -l app=hello


## CONTAINER / APPLICATION
# Enter container shell
$appPodName = kubectl get pod -n ingress-tls -l app=hello -o jsonpath="{.items[0].metadata.name}"
kubectl exec -n ingress-tls -it $appPodName /bin/sh

# Show listening ports (eg 80, 443)
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


# Cluster API check within container
# check if secret exists
ls /var/run/secrets/kubernetes.io/serviceaccount/

# [OPTIONAL] confirm namespace
cat /var/run/secrets/kubernetes.io/serviceaccount/namespace; echo

# get service IP of master (run outside of pod)
kubectl get services

# check base connectivity from cluster inside
# expect "Unauthorized"
curl -k https://10.0.0.1

# connect using tokens
TOKEN_VALUE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
echo $TOKEN_VALUE
curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H  "Authorization: Bearer $TOKEN_VALUE" https://10.0.0.1
# expect API urls listed
```

## NGINX Ingress Troubleshooting

```powershell
# INGRESS
# List all ingress resources
kubectl get ing -A

# Describe ingress
kubectl describe ing hello --namespace ingress-tls


# INGRESS CONTROLLER
# List all pods
# note all "nginx-ingress" pods
kubectl get pod --namespace ingress-tls -o wide

# Check the Ingress Controller Logs
kubectl logs --namespace ingress-tls -l component=controller


## NGINX CONFIGURATION
# Get pod name
$ingressControllerPodName = kubectl get pod --namespace ingress-tls -l component=controller -o jsonpath="{.items[0].metadata.name}"

# Output nginx config
kubectl exec $ingressControllerPodName --namespace ingress-tls -it  cat /etc/nginx/nginx.conf > nginx.conf

# Open nginx config file in vscode
# search for hostname (eg: "nexus.thehypepipe.co.uk") and check:
# - nginx.conf for server {} > location {} blocks
# - $namespace, $ingress_name, $service_name, and $service_port are correct
code ./nginx.conf

# Check if used Services exist
kubectl get svc --all-namespaces

# Check Stats within Controller pod
kubectl exec -it $ingressControllerPodName /bin/bash
curl http://localhost/nginx_status

# Check default backend pod
kubectl describe pod --namespace ingress-tls -l component=default-backend
```

## Reference

- [https://managedkube.com/kubernetes/trace/ingress/service/port/not/matching/pod/k8sbot/2019/02/13/trace-ingress.html](https://managedkube.com/kubernetes/trace/ingress/service/port/not/matching/pod/k8sbot/2019/02/13/trace-ingress.html)
- [https://kubernetes.github.io/ingress-nginx/troubleshooting/](https://kubernetes.github.io/ingress-nginx/troubleshooting/)
