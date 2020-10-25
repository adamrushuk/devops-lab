# https://github.com/Azure/aad-pod-identity
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: external-dns
  namespace: aad-pod-identity
spec:
  type: 0
  ResourceID: ${managedIdentityResourceID}
  ClientID: ${managedIdentityClientID}

---

apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: external-dns
  namespace: aad-pod-identity
spec:
  AzureIdentity: external-dns
  Selector: external-dns
