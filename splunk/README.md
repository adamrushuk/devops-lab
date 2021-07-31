# Splunk

Used for Splunk related testing.

## Installation

### Terraform

Build an AKS cluster:

```bash
# Init
cd ./splunk
terraform init #-upgrade

# Apply
terraform apply

# Outputs
terraform output

---

# Delete
terraform destroy
```

### Splunk Operator

There is a current issue with [Admin Installation for All Namespaces](https://github.com/splunk/splunk-operator/issues/206),
so use the [non-admin user method](https://github.com/splunk/splunk-operator/blob/develop/docs/Install.md#installation-using-a-non-admin-user).

#### Install

Install the Splunk Operator as a non-admin user.

```bash
# create namespace
kubectl create namespace splunk-operator

# an admin needs to install the CRDs
kubectl apply -f https://github.com/splunk/splunk-operator/releases/download/1.0.1/splunk-operator-crds.yaml

# install splunk operator into namespace
# v1.0.1 doesnt currently work - I've raised this issue: https://github.com/splunk/splunk-operator/issues/373
kubectl apply -f https://github.com/splunk/splunk-operator/releases/download/1.0.1/splunk-operator-noadmin.yaml  --namespace splunk-operator


# 1.0.0 works
kubectl apply -f https://github.com/splunk/splunk-operator/releases/download/1.0.0/splunk-operator-crds.yaml
kubectl apply -f https://github.com/splunk/splunk-operator/releases/download/1.0.0/splunk-operator-noadmin.yaml --namespace splunk-operator
```

### Splunk Deployments

After deploying one of the methods below, [get the password](https://github.com/splunk/splunk-operator/blob/develop/docs/Examples.md#reading-global-kubernetes-secret-object)
by running the following code:

```bash
# kubectl get secret splunk-<desired_namespace>-secret -o go-template=' {{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}'
kubectl get secret --namespace splunk-operator splunk-splunk-operator-secret -o go-template=' {{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}'
```

You can then port-forward to the pod and view the web interface:

```bash
kubectl port-forward splunk-s1-standalone-0 8000
kubectl port-forward --namespace splunk-operator splunk-single-standalone-0 8000
```

#### Standalone

https://github.com/splunk/splunk-operator/blob/develop/docs/Examples.md#creating-a-clustered-deployment

```bash
cat <<EOF | kubectl apply --namespace splunk-operator -f -
apiVersion: enterprise.splunk.com/v1
kind: Standalone
metadata:
  name: single
  finalizers:
  - enterprise.splunk.com/delete-pvc
EOF
```

#### Cluster Master and Indexers

https://github.com/splunk/splunk-operator/blob/develop/docs/Examples.md#indexer-clusters

```bash
# Cluster Master
cat <<EOF | kubectl apply -f -
apiVersion: enterprise.splunk.com/v1
kind: ClusterMaster
metadata:
  name: cm
  finalizers:
  - enterprise.splunk.com/delete-pvc
EOF

# Indexers
cat <<EOF | kubectl apply -f -
apiVersion: enterprise.splunk.com/v1
kind: IndexerCluster
metadata:
  name: example
  finalizers:
  - enterprise.splunk.com/delete-pvc
spec:
  clusterMasterRef:
    name: cm
EOF
```
