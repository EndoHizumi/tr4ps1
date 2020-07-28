
function Read-WorkTime {
    param([String] $target_date = "*")
    [String] $data_directory = $env:attendance_directory
    [String]
    $is_all = $target_date -eq "*"

    $worktime += Convertfrom-Csv (Get-Content (Join-Path $data_directory "worktime.csv")).Trim()
    if ($is_all) {
        Convert-AtendanceObject $worktime
    }
    else {
        Convert-AtendanceObject ($worktime | Where-Object { $_.date -match $target_date })
    }
    
}

function Convert-AtendanceObject {
    # 日毎に分解する処理
    # 日付をキーにした辞書の中に勤怠データを追加していく
    # input
    # date       time     state
    # ----       ----     -----
    # 2020/03/02 10:05:02 begin
    # 2020/03/02 10:05:34 login
    # 2020/03/02 18:58:11 logout
    # 2020/03/02 18:58:14 fin
    #
    # output
    # @{"2020/03/01" = [ 
    #                     [PSCustomObject] @{
    #                                         date:2020/03/01;
    #                                         begin:10:00:00;
    #                                         login=10:05:00;
    #                                         logout=18:30:00;
    #                                         fin=18:30:10
    #                                       }
    #                     ]
    # }
    # 
    param($attendances)
    [System.Collections.Specialized.OrderedDictionary]$attendance_set = [ordered]@{ }
    foreach ($attendance in $attendances) {
        if (!($attendance_set.Contains($attendance.date))) {
            $attendance_set[$attendance.date] = @{ }
        }
        if(($attendance.state -eq 'begin') -and $attendance_set[$attendance.date].Contains('begin')){
            continue
        }
        if(($attendance.state -eq 'login') -and $attendance_set[$attendance.date].Contains('login')){
            continue
        }
        $attendance_set[$attendance.date][$attendance.state] = $attendance.time
    }
    $attendance_set
}

Export-ModuleMember -Function Read-WorkTime
