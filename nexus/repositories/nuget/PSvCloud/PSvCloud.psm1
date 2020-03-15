# Get public and private function files
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

# Dot source the files
foreach ($FunctionFile in @($Public + $Private)) {

    try {

        . $FunctionFile.fullname

    }
    catch {

        Write-Error -Message "Failed to import function $($FunctionFile.fullname): $_"
    }
}

# Export the Public modules
Export-ModuleMember -Function $Public.Basename
