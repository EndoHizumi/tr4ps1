$ErrorActionPreference="stop"
$my_document_path = ([Environment]::GetFolderPath([Environment+SpecialFolder]::MyDocuments))
$module_path = (Join-Path $my_document_path "WindowsPowerShell\Modules\TimeRecordeeer\")
if (-not (Test-Path $module_path)) {
    New-Item -Path $module_path -ItemType "Directory" | Out-Null
}
Copy-Item ".\functions\*" -Destination $module_path -force
# Move-Item (Join-Path $module_path "./functions") (Join-Path $module_path "\TimeRecordeeer") -Force

"$module_path\*.psm1" |
Resolve-Path|
Where-Object{!$_.path.Tolower().contains(".tests.")} |
ForEach-Object{
    Import-Module $_.path -Force
    "Import-Module $($_.path) -Force" | Out-File -FilePath $PROFILE -Encoding utf8 -Append
}
