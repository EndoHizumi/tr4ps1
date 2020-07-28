$ErrorActionPreference="stop"
trap{
    write-host -ForegroundColor Red "`r`ninstall failed.`r`nfinish install modules.`r`n"
    break
}
$PSModulePath = if([Environment]::OSVersion.Platform -eq "Unix"){
    $env:PSModulePath -split ":"
}else{
    $env:PSModulePath -split ";"
}
Write-Host "`r`nbegin install modules"
Write-Host "ModulePath: $($PSModulePath[0])`r`n"
$module_path = (Join-Path $PSModulePath[0] "\TimeRecordeeer\")
if (-not (Test-Path $module_path)) {
    New-Item -Path $module_path -ItemType "Directory" | Out-Null
}
Copy-Item ".\functions\*" -Destination $module_path -force

"$module_path\*.psm1" |
Resolve-Path|
Where-Object{!$_.path.Tolower().contains(".tests.")} |
ForEach-Object{
    Write-Host "load module $([System.IO.Path]::GetFileName($_))"
    Import-Module $_.path -Force
    "Import-Module $($_.path) -Force" | Out-File -FilePath (Join-Path $module_path "importModules.ps1") -Encoding utf8 -Append
}

$importString = "Import-Module $(Join-Path $module_path "importModules.ps1") -Force"
if (-Not (Test-Path $profile)){
    new-item -ItemType "file" -Path $profile -Force | Out-Null
    $importString | Out-File -FilePath $profile -Encoding utf8
}

if (-Not @(Get-Content $profile).Contains($importString)){
   $importString | Out-File -FilePath $profile -Encoding utf8
}
write-host "`r`n install successed.`r`n"
write-host "finish install modules.`r`n"
get-module | format-table