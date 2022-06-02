# powershell function app example

## usage

```bash
# login via service principle
azh

# init
cd terraform/examples/function-app
terraform init

# show plan and apply
terraform apply

# show outputs
terraform output function
terraform output function_url

# test function
eval curl $(terraform output --raw function_url)?Name=Adam

# CLEANUP
terraform destroy
```
