
function Send-WorkTime([String] $state) {
    . "${PSScriptRoot}\freee.ps1"
    $freee = [freee]::new()
    $freee.emboss($state)
}

Export-ModuleMember -Function Send-WorkTime