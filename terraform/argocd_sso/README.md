<!-- omit in toc -->
# Argo CD Notes

A collection of notes whilst testing Argo CD.

Full SSO configuration currently cannot be done with Terraform, so I've partial automated the Application Registration,
and it's Service Principle (which makes an "Enterprise App"), but there are manual steps afterwards:

- Add `Sign on URL`
- Add `email` User Claim
- Create `SAML Signing Cert`
- Download SAML cert (base64), ready for the ConfigMap yaml
- Create yaml ConfigMaps for SSO and RBAC
- Apply ConfigMaps

<!-- omit in toc -->
## Contents

- [Reference](#reference)
- [Getting Started](#getting-started)
- [Add Repository](#add-repository)
- [Configure SSO for Argo CD](#configure-sso-for-argo-cd)

## Reference

- https://github.com/argoproj/argo-cd/blob/master/docs/faq.md#i-forgot-the-admin-password-how-do-i-reset-it

## Getting Started

Use `--grpc-web` if you get the `argocd transport: received the unexpected content-type "text/plain; charset=utf-8"` error

```bash
# vars
ARGO_SERVER="argocd.thehypepipe.co.uk"

# install
VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd

# show version
argocd version --grpc-web --server "$ARGO_SERVER"

# get admin password
# default password is server pod name, eg: "argocd-server-89c6cd7d4-h7vmn"
ARGO_ADMIN_PASSWORD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)

# login
argocd logout -h
argocd logout "$ARGO_SERVER"
argocd login -h
argocd login "$ARGO_SERVER" --grpc-web --username admin --password "$ARGO_ADMIN_PASSWORD"

# change password
read -s NEW_ARGO_ADMIN_PASSWORD
# echo "$NEW_ARGO_ADMIN_PASSWORD"
argocd account update-password --grpc-web -h
argocd account update-password --grpc-web --account admin --current-password "$ARGO_ADMIN_PASSWORD" --new-password "$NEW_ARGO_ADMIN_PASSWORD"

# test new admin password
argocd logout "$ARGO_SERVER"
argocd login "$ARGO_SERVER" --grpc-web --username admin --password "$NEW_ARGO_ADMIN_PASSWORD"

# account tasks
argocd account list
argocd account -h

# misc
argocd -h
```

## Add Repository

```bash
# Add a Git repository via SSH using a private key for authentication, ignoring the server's host key
# argocd repo add git@github.com:adamrushuk/charts-private.git --insecure-ignore-host-key --ssh-private-key-path ~/.ssh/id_ed25519
argocd repo add -h
argocd repo add git@github.com:adamrushuk/charts-private.git --ssh-private-key-path ~/.ssh/id_ed25519

# add known_host entries for private git server
ssh-keyscan gitlab.thehypepipe.co.uk | argocd cert add-ssh --batch

# create ssh key for private git repo access
# ~/.ssh/id_ed25519
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_argocd -C "argocd@gitlab.thehypepipe.co.uk"
ll ~/.ssh

# check public key fingerprint
ssh-keygen -lf ~/.ssh/id_ed25519_argocd.pub

# copy public key and enter into source git repo settings
# eg, GitLab repo deploy key: https://gitlab.thehypepipe.co.uk/helm-charts/-/settings/repository > Deploy Keys
cat ~/.ssh/id_ed25519_argocd.pub

# add helm chart repository
argocd repo add git@gitlab.thehypepipe.co.uk/helm-charts.git --ssh-private-key-path ~/.ssh/id_ed25519_argocd

# show repo
argocd repo list
```

## Configure SSO for Argo CD

https://argoproj.github.io/argo-cd/operator-manual/user-management/microsoft/

```bash
# subscription where ArgoCD is deployed
AR-Dev

# created new AAD groups, eg:
AR-Dev_ArgoCD_Admin
AR-Dev_ArgoCD_ReadOnly

# created argo enterprise app
AR-Dev_ArgoCD


# Basic SAML Configuration
# Identifier (Entity ID)
https://argocd.thehypepipe.co.uk/api/dex/callback
# Reply URL (Assertion Consumer Service URL)
https://argocd.thehypepipe.co.uk/api/dex/callback
# Sign on URL
https://argocd.thehypepipe.co.uk/auth/login

# User Attributes & Claims
# + Add new claim | Name: email | Source: Attribute | Source attribute: user.userprincipalname
+ Add new claim | Name: email | Source: Attribute | Source attribute: user.primaryauthoritativeemail

+ Add group claim | Which groups: All groups | Source attribute: Group ID | Customize: True | Name: Group | Namespace: <empty> | Emit groups as role claims: False

# Create a "Sign SAML assertion" SAML Signing Cert (SHA-256)
# Download and base64 the cert, ready for the ConfigMap yaml

# Login URL (ssoURL)
https://login.microsoftonline.com/<TENANT_ID>/saml2
# Azure AD Identifier
https://sts.windows.net/<TENANT_ID>/
# Logout URL
https://login.microsoftonline.com/<TENANT_ID>/saml2


# SSO: User Attributes & Claims
# select user.userprincipalname instead of user.mail
+ Add new claim | Name: email | Source: Attribute | Source attribute: user.userprincipalname




## Create RBAC patch ##
# RBAC vars
ARGO_ADMIN_GROUP_NAME="AR-Dev_ArgoCD_Admins"
ARGO_ADMIN_GROUP_ID=$(az ad group show --group "$ARGO_ADMIN_GROUP_NAME" --query "objectId" --output tsv)

# Create RBAC patch yaml
cat > argocd-rbac-cm-patch.yaml << EOF
# Patch ConfigMap to add RBAC config
data:
  policy.default: role:readonly

  # Map AAD Group Object Id to an Argo CD role
  # (Nested groups work fine)
  # g, <AZURE_AD_GROUP_ID>, role:admin
  policy.csv: |
    g, $ARGO_ADMIN_GROUP_ID, role:admin
EOF

# Apply yaml RBAC patch for default admin and readonly roles
kubectl patch configmap/argocd-rbac-cm --namespace argocd --type merge --patch "$(cat argocd-rbac-cm-patch.yaml)"



## Create SSO patch yaml ##
# SSO vars
ARGO_FQDN="argocd.thehypepipe.co.uk"
TENANT_ID=$(az account show --query "tenantId" --output tsv)
# assumes SAML Signing Certificate has been downloaded/saved as "ArgoCD.cer" (choosing Certificate (Base64) option)
SAML_CERT_BASE64=$(cat ArgoCD.cer | base64)
echo "$SAML_CERT_BASE64"

# created indented string ready for caData YAML multi-line block
SAML_CERT_BASE64_INDENTED=$(cat ArgoCD.cer | base64 | sed 's/^/          /')
echo "$SAML_CERT_BASE64_INDENTED"

cat > argocd-cm-sso-patch.yaml << EOF
# Patch ConfigMap to add dex SSO config
# source: https://argoproj.github.io/argo-cd/operator-manual/user-management/microsoft/
data:
  dex.config: |
    logger:
      level: debug
      format: json
    connectors:
    - type: saml
      id: saml
      name: saml
      config:
        entityIssuer: https://$ARGO_FQDN/api/dex/callback
        ssoURL: https://login.microsoftonline.com/$TENANT_ID/saml2
        caData: |
$SAML_CERT_BASE64_INDENTED
        redirectURI: https://$ARGO_FQDN/api/dex/callback
        usernameAttr: email
        emailAttr: email
        groupsAttr: Group
EOF

# Apply SSO patch
kubectl patch configmap/argocd-cm --namespace argocd --type merge --patch "$(cat argocd-cm-sso-patch.yaml)"

```
