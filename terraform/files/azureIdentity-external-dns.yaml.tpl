# https://github.com/Azure/aad-pod-identity
# TODO: delete if azure.userAssignedIdentityID works in helm_release.external_dns
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
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: external-dns
  namespace: aad-pod-identity
spec:
  azureIdentity: external-dns
  selector: external-dns
