# powershell function app example

**IMPORTANT**: It can take a while for the `HttpTrigger1` function to show within the `Function App > Function` screen.

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
