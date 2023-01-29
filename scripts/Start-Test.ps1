# Start Pester tests

#region Vars
# Set preferences
$VerbosePreference = if ($env:CI_DEBUG -eq "true") { "Continue" } else { "SilentlyContinue" }
# Ensure any PowerShell errors fail the build (try/catch wont work for non-PowerShell CLI commands)
$ErrorActionPreference = "Stop"
#endregion

Write-Verbose "Started in folder: [$(Get-Location)]"
Write-Verbose "STARTED: pwsh test task in current folder: [$(Get-Location)]"

# Install Pester
$taskMessage = "Installing Pester "
Write-Verbose "STARTED: $taskMessage..."
try {
    Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"
    Install-Module -Name "Pester" -Scope "CurrentUser" -Repository "PSGallery" -MinimumVersion 5.3.0 -Verbose

    Write-Verbose "FINISHED: $taskMessage."
}
catch {
    Write-Error "ERROR: $taskMessage." -ErrorAction "Continue"
    throw
}

# Run Pester
$taskMessage = "Running Pester tests"
Write-Verbose "STARTED: $taskMessage..."
try {
    # $testScripts = Get-ChildItem -Path "*.Tests.ps1"
    # Invoke-Pester -Script $testScripts -PassThru -OutputFormat "JUnitXml" -OutputFile "pester-test-results.xml" -Verbose -ErrorAction "Stop"
    Invoke-Pester -Path './tests' -CI -Verbose
    Write-Verbose "FINISHED: $taskMessage."
}
catch {
    Write-Error "ERROR: $taskMessage." -ErrorAction "Continue"
    throw
}

Write-Verbose "FINISHED: pwsh test task"
