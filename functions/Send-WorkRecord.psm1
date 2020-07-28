function Send-WorkRecord([String] $date) {
    Import-Module "${PSScriptRoot}\Read-WorkTime.psm1"
    . "${PSScriptRoot}\freee.ps1"
    $freee = [freee]::new()

    $attendanceDate = (Read-WorkTime $date)[1].item($date)
    $freee.WriteAttendance($attendanceDate.login, "14:00", "15:00", $attendanceDate.logout)
}

Export-ModuleMember -Function Send-WorkRecord