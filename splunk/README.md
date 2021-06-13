# Splunk

Used for Splunk related testing.

## Install

### Terraform

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

```bash
# install
kubectl create namespace splunk-operator
kubectl apply -f https://github.com/splunk/splunk-operator/releases/download/1.0.0/splunk-operator-install.yaml --namespace splunk-operator


# install custom resource definitions
kubectl apply -f https://github.com/splunk/splunk-operator/releases/download/1.0.1/splunk-operator-crds.yaml
kubectl apply -f wget -O splunk-operator.yaml https://github.com/splunk/splunk-operator/releases/download/1.0.1/splunk-operator-install.yaml
kubectl apply -f https://github.com/splunk/splunk-operator/releases/download/1.0.1/splunk-operator-cluster.yaml



# install splunk operator into namespace
kubectl create namespace splunk-operator
kubectl config set-context --current --namespace=<NAMESPACE>
kubectl apply -f https://github.com/splunk/splunk-operator/releases/download/1.0.1/splunk-operator-noadmin.yaml
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
