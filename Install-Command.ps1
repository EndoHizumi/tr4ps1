$ErrorActionPreference="stop"
Write-Host "install modules`r`n"
$module_path = (Join-Path ($env:PSModulePath -split ":")[0] "\TimeRecordeeer\")
if (-not (Test-Path $module_path)) {
    New-Item -Path $module_path -ItemType "Directory" | Out-Null
}
Copy-Item ".\functions\*" -Destination $module_path -force

"$module_path\*.psm1" |
Resolve-Path|
Where-Object{!$_.path.Tolower().contains(".tests.")} |
ForEach-Object{
    Write-Host "load module $([System.IO.Path]::GetFileName($_))`r`n"
    Import-Module $_.path -Force
    "Import-Module $($_.path) -Force" | Out-File -FilePath (Join-Path $module_path "importModules.ps1") -Encoding utf8 -Append
}

$importString = "Import-Module $(Join-Path $module_path "importModules.ps1") -Force"
if (-Not (Test-Path $profile)){
    new-item -ItemType "file" -Path $profile -Force
    $importString | Out-File -FilePath $profile -Encoding utf8
}

if (-Not @(Get-Content $profile).Contains($importString)){
   $importString | Out-File -FilePath $profile -Encoding utf8
}
write-host "install successed.`r`n"
get-module