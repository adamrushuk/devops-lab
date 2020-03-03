# Enable verbose output
if ($env:CI_DEBUG -eq "true") { $VerbosePreference = "Continue" }

Write-Verbose "Started in folder: [$(Get-Location)]"
Write-Verbose "Changing directory to test folder..."
Set-Location "test"
Write-Verbose "STARTED: pwsh test tasks in current folder: [$(Get-Location)]"

# Tests
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

Write-Verbose "FINISHED: pwsh test tasks"
