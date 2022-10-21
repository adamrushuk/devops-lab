# Terraform

## usage

```bash
# login via service principle
azh

# init
cd ./terraform
terraform init -backend=false -input=false

# validate
terraform validate

# show plan and apply
terraform apply

# show outputs
# terraform output function

# test function
# eval curl $(terraform output --raw function_url)?Name=Adam
# eval curl $(terraform output --raw function_url)?Name=Tasha


# CLEANUP
terraform destroy
```

**PRE-COMMIT-TERRAFORM DOCS** content will be automatically created below:

---

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | 2.2.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.29.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.27.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.7.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.14.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.2 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |
| <a name="requirement_template"></a> [template](#requirement\_template) | ~> 2.2 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 3.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.2.0 |
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 2.29.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.27.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.7.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.14.0 |
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.2 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.1 |
| <a name="provider_template"></a> [template](#provider\_template) | ~> 2.2 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 3.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aks"></a> [aks](#module\_aks) | adamrushuk/aks/azurerm | ~> 1.1.0 |

## Resources

| Name | Type |
|------|------|
| [azuread_application.argocd](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_password.argocd](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.argocd](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal.msgraph](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_application_insights.appinsights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_linux_function_app.func_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_log_analytics_solution.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution) | resource |
| [azurerm_log_analytics_workspace.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.aks_dns_mi_to_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_dns_mi_to_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_mi_aks_node_rg_mi_operator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_mi_aks_node_rg_vm_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_mi_kv_certs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_mi_kv_keys](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_mi_kv_secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.func_app_aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.func_app_storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.velero_mi_aks_node_rg_vm_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.velero_mi_velero_storage_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_service_plan.func_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_account.func_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account.velero](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_blob.func_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) | resource |
| [azurerm_storage_container.func_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_container.velero](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_user_assigned_identity.external_dns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.velero](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [helm_release.aad_pod_identity](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.akv2k8s](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cert_manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.external_dns](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.kured](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.nexus](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.nginx](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.velero](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.aad_pod_identity](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.akv2k8s](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.external_dns](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.gitlab](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.kured](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.nexus](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_namespace.velero](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.velero_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [local_sensitive_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [null_resource.argocd_apps](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.argocd_cert_sync](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.argocd_cm](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.argocd_configure](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.argocd_rbac_cm](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.argocd_secret](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.azureIdentity_external_dns](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.gitlab_cert_sync](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.nexus_cert_sync](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [archive_file.func_app](https://registry.terraform.io/providers/hashicorp/archive/2.2.0/docs/data-sources/file) | data source |
| [azuread_application_published_app_ids.well_known](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application_published_app_ids) | data source |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azuread_group.argocd_admins](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_dns_zone.dns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/dns_zone) | data source |
| [azurerm_key_vault.kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_resource_group.aks_node_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.dns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [template_file.azureIdentities](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aad_pod_identity_chart_version"></a> [aad\_pod\_identity\_chart\_version](#input\_aad\_pod\_identity\_chart\_version) | https://github.com/Azure/aad-pod-identity/blob/master/charts/aad-pod-identity/Chart.yaml#L4 helm search repo aad-pod-identity/aad-pod-identity | `string` | `"4.1.10"` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The admin username of the VMs that will be deployed | `string` | `"sysadmin"` | no |
| <a name="input_agent_pool_enable_auto_scaling"></a> [agent\_pool\_enable\_auto\_scaling](#input\_agent\_pool\_enable\_auto\_scaling) | n/a | `bool` | `false` | no |
| <a name="input_agent_pool_node_count"></a> [agent\_pool\_node\_count](#input\_agent\_pool\_node\_count) | Agent Pool | `number` | `1` | no |
| <a name="input_agent_pool_node_max_count"></a> [agent\_pool\_node\_max\_count](#input\_agent\_pool\_node\_max\_count) | n/a | `any` | `null` | no |
| <a name="input_agent_pool_node_min_count"></a> [agent\_pool\_node\_min\_count](#input\_agent\_pool\_node\_min\_count) | n/a | `any` | `null` | no |
| <a name="input_agent_pool_profile_disk_size_gb"></a> [agent\_pool\_profile\_disk\_size\_gb](#input\_agent\_pool\_profile\_disk\_size\_gb) | n/a | `number` | `30` | no |
| <a name="input_agent_pool_profile_name"></a> [agent\_pool\_profile\_name](#input\_agent\_pool\_profile\_name) | n/a | `string` | `"default"` | no |
| <a name="input_agent_pool_profile_os_type"></a> [agent\_pool\_profile\_os\_type](#input\_agent\_pool\_profile\_os\_type) | n/a | `string` | `"Linux"` | no |
| <a name="input_agent_pool_profile_vm_size"></a> [agent\_pool\_profile\_vm\_size](#input\_agent\_pool\_profile\_vm\_size) | n/a | `string` | `"Standard_D4s_v3"` | no |
| <a name="input_aks_admins_aad_group_name"></a> [aks\_admins\_aad\_group\_name](#input\_aks\_admins\_aad\_group\_name) | Name an existing Azure AD group for AKS admins | `string` | `"AKS-Admins"` | no |
| <a name="input_aks_config_path"></a> [aks\_config\_path](#input\_aks\_config\_path) | n/a | `string` | `"./azurek8s_config"` | no |
| <a name="input_aks_container_insights_enabled"></a> [aks\_container\_insights\_enabled](#input\_aks\_container\_insights\_enabled) | Should Container Insights monitoring be enabled | `bool` | `true` | no |
| <a name="input_akv2k8s_chart_version"></a> [akv2k8s\_chart\_version](#input\_akv2k8s\_chart\_version) | https://github.com/SparebankenVest/azure-key-vault-to-kubernetes https://github.com/SparebankenVest/helm-charts/tree/gh-pages/akv2k8s https://github.com/SparebankenVest/public-helm-charts/blob/master/stable/akv2k8s/Chart.yaml#L5 helm search repo spv-charts/akv2k8s | `string` | `"2.2.2"` | no |
| <a name="input_argocd_admin_password"></a> [argocd\_admin\_password](#input\_argocd\_admin\_password) | n/a | `string` | `"__ARGOCD_ADMIN_PASSWORD__"` | no |
| <a name="input_argocd_admins_aad_group_name"></a> [argocd\_admins\_aad\_group\_name](#input\_argocd\_admins\_aad\_group\_name) | argo cd | `string` | `"ArgoCD_Admins"` | no |
| <a name="input_argocd_app_reg_name"></a> [argocd\_app\_reg\_name](#input\_argocd\_app\_reg\_name) | n/a | `string` | `"sp_argocd_oidc"` | no |
| <a name="input_argocd_apps_path"></a> [argocd\_apps\_path](#input\_argocd\_apps\_path) | n/a | `string` | `"files/argocd-apps.yaml"` | no |
| <a name="input_argocd_cert_sync_yaml_path"></a> [argocd\_cert\_sync\_yaml\_path](#input\_argocd\_cert\_sync\_yaml\_path) | n/a | `string` | `"files/argocd-akvs-certificate-sync.yaml"` | no |
| <a name="input_argocd_chart_version"></a> [argocd\_chart\_version](#input\_argocd\_chart\_version) | argo cd https://github.com/argoproj/argo-helm/blob/master/charts/argo-cd/Chart.yaml#L5 helm search repo argo/argo-cd helm search repo -l argo/argo-cd \| head -n 20 * also update terraform/helm/argocd\_default\_values.yaml | `string` | `"5.6.0"` | no |
| <a name="input_argocd_cm_yaml_path"></a> [argocd\_cm\_yaml\_path](#input\_argocd\_cm\_yaml\_path) | n/a | `string` | `"files/argocd-cm-patch.tmpl.yaml"` | no |
| <a name="input_argocd_fqdn"></a> [argocd\_fqdn](#input\_argocd\_fqdn) | n/a | `string` | `"__ARGOCD_FQDN__"` | no |
| <a name="input_argocd_image_tag"></a> [argocd\_image\_tag](#input\_argocd\_image\_tag) | https://hub.docker.com/r/argoproj/argocd/tags * also update cli version: terraform/files/scripts/argocd\_config.sh#L22 | `string` | `"v2.4.15"` | no |
| <a name="input_argocd_rbac_cm_yaml_path"></a> [argocd\_rbac\_cm\_yaml\_path](#input\_argocd\_rbac\_cm\_yaml\_path) | n/a | `string` | `"files/argocd-rbac-cm-patch.tmpl.yaml"` | no |
| <a name="input_argocd_secret_yaml_path"></a> [argocd\_secret\_yaml\_path](#input\_argocd\_secret\_yaml\_path) | n/a | `string` | `"files/argocd-secret-patch.tmpl.yaml"` | no |
| <a name="input_azure_resourcegroup_name"></a> [azure\_resourcegroup\_name](#input\_azure\_resourcegroup\_name) | n/a | `string` | `"__AKS_RG_NAME__"` | no |
| <a name="input_azureidentity_external_dns_yaml_path"></a> [azureidentity\_external\_dns\_yaml\_path](#input\_azureidentity\_external\_dns\_yaml\_path) | n/a | `string` | `"files/azureIdentity-external-dns.yaml.tpl"` | no |
| <a name="input_azurerm_kubernetes_cluster_name"></a> [azurerm\_kubernetes\_cluster\_name](#input\_azurerm\_kubernetes\_cluster\_name) | AKS | `string` | `"__AKS_CLUSTER_NAME__"` | no |
| <a name="input_cert_manager_chart_version"></a> [cert\_manager\_chart\_version](#input\_cert\_manager\_chart\_version) | https://hub.helm.sh/charts/jetstack/cert-manager helm search repo jetstack/cert-manager | `string` | `"v1.10.0"` | no |
| <a name="input_dns_resource_group_name"></a> [dns\_resource\_group\_name](#input\_dns\_resource\_group\_name) | DNS | `string` | `"__DNS_RG_NAME__"` | no |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | n/a | `string` | `"__ROOT_DOMAIN_NAME__"` | no |
| <a name="input_external_dns_chart_version"></a> [external\_dns\_chart\_version](#input\_external\_dns\_chart\_version) | https://bitnami.com/stack/external-dns/helm https://github.com/bitnami/charts/blob/master/bitnami/external-dns/Chart.yaml helm search repo bitnami/external-dns helm search repo -l bitnami/external-dns | `string` | `"6.10.2"` | no |
| <a name="input_func_app_sas_expires_in_hours"></a> [func\_app\_sas\_expires\_in\_hours](#input\_func\_app\_sas\_expires\_in\_hours) | Function Apps | `string` | `"2190h"` | no |
| <a name="input_gitlab_cert_sync_yaml_path"></a> [gitlab\_cert\_sync\_yaml\_path](#input\_gitlab\_cert\_sync\_yaml\_path) | gitlab | `string` | `"files/gitlab-akvs-certificate-sync.yaml"` | no |
| <a name="input_helm_chart_repo_deploy_private_key"></a> [helm\_chart\_repo\_deploy\_private\_key](#input\_helm\_chart\_repo\_deploy\_private\_key) | n/a | `string` | `"__HELM_CHART_REPO_DEPLOY_PRIVATE_KEY__\n"` | no |
| <a name="input_ifttt_webhook_key"></a> [ifttt\_webhook\_key](#input\_ifttt\_webhook\_key) | n/a | `string` | `"__IFTTT_WEBHOOK_KEY__"` | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | n/a | `string` | `"__KEY_VAULT_NAME__"` | no |
| <a name="input_key_vault_resource_group_name"></a> [key\_vault\_resource\_group\_name](#input\_key\_vault\_resource\_group\_name) | n/a | `string` | `"__KEY_VAULT_RESOURCE_GROUP_NAME__"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | region Versions version used for both main AKS API service, and default node pool https://github.com/Azure/AKS/releases az aks get-versions --location eastus --output table pwsh -Command "(az aks get-versions --location uksouth \| convertfrom-json).orchestrators \| where default" | `string` | `"1.23.12"` | no |
| <a name="input_kured_chart_version"></a> [kured\_chart\_version](#input\_kured\_chart\_version) | https://github.com/kubereboot/charts/tree/main/charts/kured helm search repo kubereboot/kured | `string` | `"4.0.2"` | no |
| <a name="input_kured_image_tag"></a> [kured\_image\_tag](#input\_kured\_image\_tag) | https://github.com/kubereboot/kured#kubernetes--os-compatibility | `string` | `"1.10.2"` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"__LOCATION__"` | no |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | n/a | `string` | `"__PREFIX__-la-workspace-001"` | no |
| <a name="input_nexus_base_domain"></a> [nexus\_base\_domain](#input\_nexus\_base\_domain) | Nexus | `string` | `"__ROOT_DOMAIN_NAME__"` | no |
| <a name="input_nexus_cert_email"></a> [nexus\_cert\_email](#input\_nexus\_cert\_email) | n/a | `string` | `"__EMAIL_ADDRESS__"` | no |
| <a name="input_nexus_cert_sync_yaml_path"></a> [nexus\_cert\_sync\_yaml\_path](#input\_nexus\_cert\_sync\_yaml\_path) | akv2k8s | `string` | `"files/nexus-akvs-certificate-sync.yaml"` | no |
| <a name="input_nexus_chart_version"></a> [nexus\_chart\_version](#input\_nexus\_chart\_version) | https://github.com/adamrushuk/charts/releases helm search repo adamrushuk/sonatype-nexus | `string` | `"0.3.1"` | no |
| <a name="input_nexus_image_tag"></a> [nexus\_image\_tag](#input\_nexus\_image\_tag) | https://hub.docker.com/r/sonatype/nexus3/tags | `string` | `"3.42.0"` | no |
| <a name="input_nexus_ingress_enabled"></a> [nexus\_ingress\_enabled](#input\_nexus\_ingress\_enabled) | n/a | `string` | `"__ENABLE_TLS_INGRESS__"` | no |
| <a name="input_nexus_letsencrypt_environment"></a> [nexus\_letsencrypt\_environment](#input\_nexus\_letsencrypt\_environment) | n/a | `string` | `"__CERT_API_ENVIRONMENT__"` | no |
| <a name="input_nexus_tls_secret_name"></a> [nexus\_tls\_secret\_name](#input\_nexus\_tls\_secret\_name) | n/a | `string` | `"__K8S_TLS_SECRET_NAME__"` | no |
| <a name="input_nginx_chart_version"></a> [nginx\_chart\_version](#input\_nginx\_chart\_version) | Helm charts https://github.com/kubernetes/ingress-nginx/releases helm repo update helm search repo ingress-nginx/ingress-nginx helm search repo -l ingress-nginx/ingress-nginx \| head -5 | `string` | `"4.3.0"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Common | `string` | `"__PREFIX__"` | no |
| <a name="input_sla_sku"></a> [sla\_sku](#input\_sla\_sku) | Define the SLA under which the managed master control plane of AKS is running | `string` | `"Free"` | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public key for SSH access to the VMs | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources | `map` | <pre>{<br>  "Env": "Dev",<br>  "Owner": "Adam Rush",<br>  "Source": "terraform"<br>}</pre> | no |
| <a name="input_velero_backup_included_namespaces"></a> [velero\_backup\_included\_namespaces](#input\_velero\_backup\_included\_namespaces) | n/a | `list(string)` | <pre>[<br>  "nexus"<br>]</pre> | no |
| <a name="input_velero_backup_retention"></a> [velero\_backup\_retention](#input\_velero\_backup\_retention) | n/a | `string` | `"2h0m0s"` | no |
| <a name="input_velero_backup_schedule"></a> [velero\_backup\_schedule](#input\_velero\_backup\_schedule) | Velero backup schedule in cron format | `string` | `"0 */1 * * *"` | no |
| <a name="input_velero_chart_version"></a> [velero\_chart\_version](#input\_velero\_chart\_version) | https://github.com/vmware-tanzu/helm-charts/releases helm search repo vmware-tanzu/velero * also update terraform/helm/velero\_default\_values.yaml * also update terraform/helm/velero\_values.yaml | `string` | `"2.32.1"` | no |
| <a name="input_velero_enabled"></a> [velero\_enabled](#input\_velero\_enabled) | Should Velero be enabled | `string` | `"__VELERO_ENABLED__"` | no |
| <a name="input_velero_image_tag"></a> [velero\_image\_tag](#input\_velero\_image\_tag) | https://hub.docker.com/r/velero/velero/tags | `string` | `"v1.9.2"` | no |
| <a name="input_velero_service_principle_name"></a> [velero\_service\_principle\_name](#input\_velero\_service\_principle\_name) | n/a | `string` | `"sp_velero"` | no |
| <a name="input_velero_storage_account_name"></a> [velero\_storage\_account\_name](#input\_velero\_storage\_account\_name) | n/a | `string` | `"__VELERO_STORAGE_ACCOUNT__"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks_credentials_command"></a> [aks\_credentials\_command](#output\_aks\_credentials\_command) | n/a |
| <a name="output_aks_node_resource_group"></a> [aks\_node\_resource\_group](#output\_aks\_node\_resource\_group) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
