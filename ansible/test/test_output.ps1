Get-ChildItem test

$ErrorDetail = Get-Error

Write-Output ($ErrorDetail.CategoryInfo | ConvertTo-Json)
