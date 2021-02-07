# Adding extra SSO claim
# Set "ArgoCD" app reg (<ARGO_APP_OBJECT_ID>)
ARGO_APP_OBJECT_ID="<ARGO_APP_OBJECT_ID>"
az rest --method PATCH --uri "https://graph.microsoft.com/v1.0/applications/$ARGO_APP_OBJECT_ID" --body '{\"optionalClaims\": {\"saml2Token\": [{\"name\": \"test\", \"additionalProperties\": [\"sam_account_name\"]}]}}'

az rest --method PATCH --uri "https://graph.microsoft.com/v1.0/applications/$ARGO_APP_OBJECT_ID" --body '{\"optionalClaims\": {\"saml2Token\": [{\"name\": \"userprincipalname\", \"source\": \"user\", \"additionalProperties\": [\"email\"]}]}}'

# works via PS
$ARGO_APP_OBJECT_ID = "<ARGO_APP_OBJECT_ID>"
az rest --method PATCH --uri "https://graph.microsoft.com/v1.0/applications/$ARGO_APP_OBJECT_ID" --body '{\"optionalClaims\": {\"saml2Token\": [{\"name\": \"groups\", \"additionalProperties\": [\"sam_account_name\"]}]}}'

# add custom email claim
az rest --method PATCH --uri "https://graph.microsoft.com/v1.0/applications/$ARGO_APP_OBJECT_ID" --body '{\"optionalClaims\": {\"saml2Token\": [{\"name\": \"userprincipalname\", \"source\": \"user\", \"additionalProperties\": [\"email\"]}]}}'

# add custom group claim
az rest --method PATCH --uri "https://graph.microsoft.com/v1.0/applications/$ARGO_APP_OBJECT_ID" --body '{\"optionalClaims\": {\"saml2Token\": [{\"name\": \"groups\", \"source\": null}]}}'



# Get
az rest --method GET --uri "https://graph.microsoft.com/v1.0/applications/$ARGO_APP_OBJECT_ID"
az rest --method GET --uri "https://graph.microsoft.com/v1.0/applications/$ARGO_APP_OBJECT_ID" | clip.exe

    "optionalClaims": {
        "accessToken": [],
        "idToken": [],
        "saml2Token": [
        {
            "additionalProperties": [],
            "essential": false,
            "name": "groups",
            "source": null
        }
        ]
    },


# TF created "ArgoCD" App Reg
az rest --method GET --uri "https://graph.microsoft.com/v1.0/applications/$ARGO_APP_OBJECT_ID"

  "optionalClaims": {
    "accessToken": [],
    "idToken": [],
    "saml2Token": [
      {
        "additionalProperties": [
          "sam_account_name"
        ],
        "essential": false,
        "name": "test",
        "source": null
      }
    ]
  },

# AR-Dev_ArgoCD - App reg
az rest --method GET --uri "https://graph.microsoft.com/v1.0/applications/$ARGO_APP_OBJECT_ID"

# manual "AR-Dev_ArgoCD" Enterprise App
SERVICE_PRINCIPLE_ID="<SERVICE_PRINCIPLE_ID>"
az rest --method GET --uri "https://graph.microsoft.com/v1.0/servicePrincipals/$SERVICE_PRINCIPLE_ID"
az rest --method GET --uri "https://graph.microsoft.com/v1.0/servicePrincipals/$SERVICE_PRINCIPLE_ID" | clip.exe
