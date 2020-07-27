function Write-Worktime([String] $date, [String] $time, [String] $state) {
    [String] $data_directory = $env:attendance_directory
    [String] $file_path = (Join-Path $data_directory "worktime.csv")

    if (-Not ( Test-Path $data_directory)){
        New-Item -ItemType "directory" -Path $data_directory
        Write-Output "date,time,state" | Out-file $file_path -Encoding  UTF8
    }
    Write-Output "${date},${time},${state}" | Out-File $file_path -Encoding UTF8 -Append
}

Export-ModuleMember -Function Write-Worktime
