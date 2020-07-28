function Show-WorkTime {
    # 勤怠時間を見やすく整形して、表示する
    # input
    # "2020/03/01"
    #
    # output
    # date        begin    login    logout    fin
    # ----        -----    -----    ------    --------
    # 2020/03/01  10:00:00 10:05:00 18:30:00  18:30:10


    param([String] $target_date = "*")
    Import-Module "${PSScriptRoot}\Read-WorkTime.psm1"
    $attendance_set =  (Read-WorkTime $target_date)[0].item($target_date)
    if ($attendance_set.Count -eq 0) {
        return
    }
    $processed_atendances = @()
    foreach ($attendance in $attendance_set.GetEnumerator()) {
        $processed_atendances += @([PSCustomObject] ([ordered] @{"date" = $attendance.key; "begin" = $attendance.Value.begin; "login" = $attendance.Value.login; "logout" = $attendance.Value.logout; "fin" = $attendance.Value.fin }))
    }
    $processed_atendances | Format-Table
}

Export-ModuleMember -Function Show-WorkTime
