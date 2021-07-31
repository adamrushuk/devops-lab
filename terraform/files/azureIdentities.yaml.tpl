azureIdentities:
  "velero":
    # if not defined, then the name of azure identity will be the same as the key
    name: "velero"
    # if not defined, then the azure identity will be deployed in the same namespace as the chart
    namespace: ""
    # type 0: MSI, type 1: Service Principal
    type: 0
    # /subscriptions/subscription-id/resourcegroups/resource-group/providers/Microsoft.ManagedIdentity/userAssignedIdentities/identity-name
    resourceID: "${resourceID}"
    clientID: "${clientID}"
    binding:
      name: "velero-binding"
      # The selector will also need to be included in labels for app deployment
      selector: "velero"
