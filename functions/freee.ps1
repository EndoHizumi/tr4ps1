$ErrorActionPreference = "stop"
class freee {

    $header = @{
        Authorization = ""
        accept        = "application/json"
    }
    $company_id = ""
    $employee_id = ""

    freee() {
        $config = ConvertFrom-Json (gc "${PSScriptRoot}\config.json" -raw)
        if ($config.access_token) {
            $this.header["Authorization"] = "Bearer $($config.access_token)"
            $user_info = $this.me()
            $this.company_id = $user_info.id
            $this.employee_id = $user_info.employee_id
        }
        else {
            $token_url = "{$($config.token_url)?client_id=$($config.client_id)&redirect_uri=$($config.redirect_uri)&response_type=$($config.response_type)"
            Write-Error("config.jsonにアクセストークンが登録されていません。認証ページにログインしてアクセストークンを取得してください。 `r`n 認証ページ：$token_url")
        }
    }

    [PSCustomObject] me() {
        $res = $this.get("https://api.freee.co.jp/hr/api/v1/users/me")
        return $res.companies
    }

    [PSCustomObject] emboss($state) {
        $body = @{
            "company_id" = $this.company_id 
            "type"       = $state
            "base_date"  = $(get-date -Format "yyyy-MM-dd")
        }

        $url = "https://api.freee.co.jp/hr/api/v1/employees/$($this.employee_id)/time_clocks"
        $res = $this.post($url, $body)
        return $res        
    }

    [PSCustomObject] WriteAttendance([String] $work_begin, [String] $break_begin, [String] $break_end, [String] $work_end){
        $today = $(get-date -Format "yyyy-MM-dd")
        $body = @{
            "company_id" = $this.company_id
            "break_records" = @(@{
                "clock_in_at" = $break_begin
                "clock_out_at" = $break_end
            })
            "clock_in_at" = $work_begin
            "clock_out_at" = $work_end
        }

        $url = "https://api.freee.co.jp/hr/api/v1/employees/$($this.employee_id)/work_records/{$today}"
        $res = $this.put($url, $body)
        return $res          
    }

    [PSCustomObject] get([String] $url) {
        return $this.sendRequest("GET", $url, @{}, @{})
    }

    [PSCustomObject] post([String] $url, $body) {
        return $this.sendRequest("POST", $url, @{}, $body)
    }

    [PSCustomObject] put([String] $url, $body) {
        return $this.sendRequest("PUT", $url, @{}, $body)
    }

    [PSCustomObject] sendRequest($method, [String] $url, [System.Object] $headers, [System.Object] $body) {
        if ($headers.length -gt 0) {
            $this.header += $headers
        }

        # $res = Invoke-WebRequest -Method $method -Uri $url -Headers $this.header -Body $body
        $res = Invoke-WebRequest -Method $method -Uri $url -Headers $this.header -Body $body
        if (-Not $res.StatusCode.ToString().StartsWith("2")) {
            throw "HTTPError $($res.StatusCode) `r`n $($res.Content)"
        }
        
        return ConvertFrom-Json $res.Content

    }
}