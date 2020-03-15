# Replace tokens
param (
    $TargetFilePattern = './terraform/*.tf',
    $TokenPrefix = '__',
    $TokenSuffix = '__',

    # WARNING: this can expose sensitive information
    $DebugInsecure = $false
)

#region Vars
# Set preferences
$VerbosePreference = if ($env:CI_DEBUG -eq "true") { "Continue" } else { "SilentlyContinue" }
# Ensure any PowerShell errors fail the build (try/catch wont work for non-PowerShell CLI commands)
$ErrorActionPreference = "Stop"
#endregion


$message = "Replacing tokens in Environment variables"
Write-Output "`nSTARTED: $message..."

# Prepare env vars
$envVarHash = @{ }
foreach ($envvar in (Get-ChildItem env:)) {
    $envVarHash.Add("$($TokenPrefix)$($envvar.Name)$($TokenSuffix)", $envvar.Value)
}

if ($DebugInsecure -eq "true") {
    # Write warning to workflow
    # https://help.github.com/en/actions/reference/development-tools-for-github-actions#set-a-warning-message-warning
    # ::warning file={name},line={line},col={col}::{message}
    Write-Output "::warning ::CI_DEBUG is 'true'...showing env vars which may contain sensitive information"

    $envVarHash.GetEnumerator() | Sort-Object Name
}

# Get files
$targetFiles = (Get-ChildItem -Path $TargetFilePattern)

foreach ($targetFile in $targetFiles) {
    # Read content
    $fileContent = Get-Content -Path $targetFile -Raw

    # Replace tokens
    foreach ($item in $envVarHash.GetEnumerator()) {
        $fileContent = $fileContent -replace $item.key, $item.value
    }

    # Write content
    $fileContent | Set-Content -Path $targetFile -NoNewline

    if ($DebugInsecure -eq "true") {
        Write-Verbose "Showing content for: [$targetFile]"
        Get-Content -Path $targetFile -Raw
    }
}

Write-Output "FINISHED: $message."
