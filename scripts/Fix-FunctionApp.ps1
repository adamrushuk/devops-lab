# source: https://github.com/terraform-providers/terraform-provider-azurerm/issues/8867#issuecomment-849842849

# Fixes PowerShell function app stack version to 7, and restarts

$function = az functionapp show --name $env:FUNCTION_APP_NAME --resource-group $env:FUNCTION_APP_RG | ConvertFrom-Json

# TODO: I dont think this is required anymore as I use application_stack > powershell_core_version
if ($function.siteConfig.powerShellVersion -ne "~7") {
    Write-Host "[NoOp] Updating powershell version to ~7..."
    # az functionapp update --name $env:FUNCTION_APP_NAME --resource-group $env:FUNCTION_APP_RG --set "siteConfig.powerShellVersion=~7"
} else {
    Write-Host "Powershell version already set to to ~7"
}

# Restart Function App
Write-Host "Restarting function app [$($env:FUNCTION_APP_NAME)]..."
az functionapp restart --name $env:FUNCTION_APP_NAME --resource-group $env:FUNCTION_APP_RG

Write-Host 'FINISHED.'
