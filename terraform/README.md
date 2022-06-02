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
*auto populated information
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
