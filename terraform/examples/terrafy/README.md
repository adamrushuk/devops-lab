# Terrafy

## Install

Run my [Azure Terrafy install script](https://github.com/adamrushuk/tools-install/blob/master/aztfy.sh).

## Create Resources

Before running Azure Terrafy, some resources will need to exist.

For this test, I created a `PowerShell Core 7.2 Function App` within a Resource Group called `rg-functionapp`.

## Usage

```bash
# init
cd terraform/examples/terrafy
mkdir -p ./output

# login to your account
az login

# run aztfy
# aztfy [option] <resource group name>
aztfy -o ./output rg-functionapp

# review the resources
# select any entries that are marked with "skip", press "enter" then input the Terraform resource address in form
# of <resource type>.<resource name> (e.g. "azurerm_storage_account.func_app")

# press "w" to import into local state
```
