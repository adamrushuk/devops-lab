# Replace tokens
param (
    $targetFilePattern = './terraform/*.tf',
    $tokenPrefix = '__',
    $tokenSuffix = '__'
)

# Ensure any errors fail the build
$ErrorActionPreference = "Stop"

$message = "Replacing tokens in Environment variables"
Write-Output "`nSTARTED: $message..."

# Prepare env vars
$envVarHash = @{ }
foreach ($envvar in (Get-ChildItem env:)) {
    $envVarHash.Add("$($tokenPrefix)$($envvar.Name)$($tokenSuffix)", $envvar.Value)
}

$envVarHash.GetEnumerator() | Sort-Object Name

# Get files
$targetFiles = (Get-ChildItem -Path $targetFilePattern)

# Replace tokens
foreach ($targetFile in $targetFiles) {
    foreach ($item in $envVarHash.GetEnumerator()) {
        ((Get-Content -Path $targetFile -Raw) -replace $item.key, $item.value) | Set-Content -Path $targetFile
    }
}

Write-Output "FINISHED: $message."
