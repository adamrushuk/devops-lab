# https://github.com/Azure/aad-pod-identity
# https://azure.github.io/aad-pod-identity/docs/concepts/azureidentity/
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: external-dns
  namespace: aad-pod-identity
spec:
  type: 0
  resourceID: ${managedIdentityResourceID}
  clientID: ${managedIdentityClientID}
---
# https://azure.github.io/aad-pod-identity/docs/concepts/azureidentitybinding/
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: external-dns
  namespace: aad-pod-identity
spec:
  azureIdentity: external-dns
  selector: external-dns
