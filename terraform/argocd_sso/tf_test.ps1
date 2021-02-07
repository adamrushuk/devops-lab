# testing Terraform config for Enterprise App
# use WSL
cd ./terraform/argocd_sso

# login
az login
az account show

# init
terraform init

# apply
terraform apply

# destroy
terraform destroy
