function Login {
    $needLogin = $true
    Try {
        $content = (az account show | ConvertFrom-Json)
        if (![string]::IsNullOrEmpty($content)) {
            $needLogin = $false
        }
    }
    Catch {
        if ($_ -like "*Please run 'az login' to setup account.*") {
            $needLogin = $true
        }
        else {
            throw
        }
    }
    Write-Host
    if ($needLogin) {

        Write-Host "Logging in..." -ForegroundColor Green
        az login
    }
    else {
        Write-Host ("Already logged in as {0}" -f $content.user.name) -ForegroundColor Green
    }
}