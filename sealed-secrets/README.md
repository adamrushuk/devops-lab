# Sealed Secrets Notes

[sealed-secrets](https://github.com/bitnami-labs/sealed-secrets) is a Kubernetes controller and tool for one-way
encrypted Secrets.

**Problem**: "I can manage all my K8s config in git, except Secrets."

**Solution**: Encrypt your Secret into a SealedSecret, which is safe to store - even to a public repository. The
SealedSecret can be decrypted only by the controller running in the target cluster and nobody else
(not even the original author) is able to obtain the original Secret from the SealedSecret.

## Installation

Before installation, consider reading the [Release Notes](https://github.com/bitnami-labs/sealed-secrets/blob/main/RELEASE-NOTES.md).

### Helm Chart

Use the code below to install the official [sealed-secrets helm chart](https://github.com/bitnami-labs/sealed-secrets/tree/main/helm/sealed-secrets):

```bash
# add repo
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets

# list charts
helm search repo sealed-secrets

# list all chart versions
helm search repo sealed-secrets/sealed-secrets -l

# create namespace
kubectl create namespace sealed-secrets

# install chart (dry-run)
helm upgrade sealed-secrets sealed-secrets/sealed-secrets --install --atomic --namespace sealed-secrets --debug --dry-run

# install chart
helm upgrade sealed-secrets sealed-secrets/sealed-secrets --install --atomic --namespace sealed-secrets --debug

# show status / notes
helm status sealed-secrets --namespace sealed-secrets
```

### Kubeseal CLI

Install the kubeseal CLI by downloading the binary from [sealed-secrets/releases](https://github.com/bitnami-labs/sealed-secrets/releases).

```bash
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.15.0/kubeseal-linux-amd64 -O kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```

## Usage

The example below creates a secret, then uses kubeseal to encrypt it into a sealed-secret file.

Once the sealed-secret file is applied into the kubernetes cluster, it is decrypted server-side to create a
standard secret in the target namespace.

```bash
# create secret
# (note use of `--dry-run` - this is just a local file!)
echo -n SuperSecretPassw0rd | kubectl create secret generic mysecret --dry-run=client --from-literal=username=admin --from-file=password=/dev/stdin -o yaml > secret.yaml

# create sealed-secret using stdin/stdout
kubeseal \
  --controller-namespace sealed-secrets \
  --controller-name sealed-secrets \
  --namespace my-target-namespace \
  < secret.yaml > sealed-secret.yaml

# create namespace
kubectl create namespace my-target-namespace

# apply sealed-secret
kubectl create --namespace my-target-namespace -f sealed-secret.yaml

# show secret
kubectl get secret mysecret --namespace my-target-namespace -o yaml
```
