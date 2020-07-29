$ErrorActionPreference="stop"
trap{
    write-host -ForegroundColor Red "`r`ninstall failed.`r`nfinish install modules.`r`n"
    break
}

# ユーザーセッションのモジュールパスを取得する
$PSModulePath = if([Environment]::OSVersion.Platform -eq "Unix"){
    $env:PSModulePath -split ":"
}else{
    $env:PSModulePath -split ";"
}

# モジュールパスにfunctionsのPowerShellスクリプトをコピーする
Write-Host "`r`nbegin install modules"
Write-Host "ModulePath: $($PSModulePath[0])`r`n"
$module_path = (Join-Path $PSModulePath[0] "\TimeRecordeeer\")
if (-not (Test-Path $module_path)) {
    New-Item -Path $module_path -ItemType "Directory" | Out-Null
}
Copy-Item ".\functions\*" -Destination $module_path -force

# モジュールを読み込む
"$module_path\*.psm1" |
Resolve-Path|
Where-Object{!$_.path.Tolower().contains(".tests.")} |
ForEach-Object{
    Write-Host "load module $([System.IO.Path]::GetFileName($_))"
    Import-Module $_.path -Force
    # Profileに同じコマンドを複数書き込まないように、読み込むモジュールを指定するインポートリストファイルを作成する
    "Import-Module $($_.path) -Force" | Out-File -FilePath (Join-Path $module_path "importModules.ps1") -Encoding utf8 -Append
}

# Profileに追記する。Profileがないときは作成して書き込む
$importString = "Import-Module $(Join-Path $module_path "importModules.ps1") -Force"
if (-Not (Test-Path $profile)){
    new-item -ItemType "file" -Path $profile -Force | Out-Null
    $importString | Out-File -FilePath $profile -Encoding utf8
}

# 次回起動時に自動でモジュールを読み込まれるようにインポートリストファイルを$profileに記述する
# 既に書いてある場合は、何もしない。
if (-Not @(Get-Content $profile).Contains($importString)){
   $importString | Out-File -FilePath $profile -Encoding utf8
}
write-host "`r`ninstall successed.`r`n"
write-host "finish install modules.`r`n"
get-module | format-table