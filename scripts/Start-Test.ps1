# Start Pester tests

#region Vars
# Set preferences
$VerbosePreference = if ($env:CI_DEBUG -eq "true") { "Continue" } else { "SilentlyContinue" }
# Ensure any PowerShell errors fail the build (try/catch wont work for non-PowerShell CLI commands)
$ErrorActionPreference = "Stop"
#endregion

Write-Verbose "Started in folder: [$(Get-Location)]"
Write-Verbose "Changing directory to test folder..."
Set-Location "test"

Write-Verbose "STARTED: pwsh test task in current folder: [$(Get-Location)]"

# Install Pester
$taskMessage = "Installing Pester "
Write-Verbose "STARTED: $taskMessage..."
try {
    Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"
    Install-Module -Name "Pester" -Scope "CurrentUser" -Force

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
    $testScripts = Get-ChildItem -Path "*.tests.ps1"
    Invoke-Pester -Script $testScripts -PassThru -OutputFormat "JUnitXml" -OutputFile "pester-test-results-junit.xml" -Verbose -ErrorAction "Stop"

    Write-Verbose "FINISHED: $taskMessage."
}
catch {
    Write-Error "ERROR: $taskMessage." -ErrorAction "Continue"
    throw
}

Write-Verbose "FINISHED: pwsh test task"
