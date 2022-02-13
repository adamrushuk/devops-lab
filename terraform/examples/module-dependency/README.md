# role assignment example

## usage

```bash
# login via service principle
azh

# init
cd terraform/examples/module-dependency
terraform init

# show plan and apply
terraform apply

# change role definition permissions, then apply changes
# this should show "~ update in-place" changes
terraform apply

# test locals
terraform console
local.custom_contributor_default_not_actions
local.nsg_right_allowed_actions
local.nsg_not_actions


# CLEANUP
terraform destroy
```
