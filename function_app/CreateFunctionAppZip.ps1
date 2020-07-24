# Creates a zip file for Function App files

# Vars
$functionZipPath = Join-Path -Path $PSScriptRoot -ChildPath "..\terraform\files\function_app.zip"
$excludeList = Get-Content -Path "function_app\.funcignore"
$filesToZip = @()

# Prepare files to zip
foreach ($file in (Get-ChildItem -Path $PSScriptRoot)) {
    if ($file.name -notin $excludeList) {
        $filesToZip += $file.fullname
    }
}

# Create zip file of Function App
Compress-Archive -Path $filesToZip -DestinationPath $functionZipPath -Force

$zipHash = Get-FileHash -Path $functionZipPath

Write-Host "File hash for zip file is: [$($zipHash.Hash)]"
