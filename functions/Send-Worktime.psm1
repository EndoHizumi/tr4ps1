
function Send-WorkTime([String] $state) {
    . "./freee.ps1"
    $freee = [freee]::new()
    $freee.emboss($state)
}

Export-ModuleMember -Function Send-WorkTime