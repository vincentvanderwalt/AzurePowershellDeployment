function Login {
    $needLogin = $true
    Try {
        $content = Get-AzureRmContext
        if ($content) {
            $needLogin = ([string]::IsNullOrEmpty($content.Account))
        }
    }
    Catch {
        if ($_ -like "*Login-AzureRmAccount to login*") {
            $needLogin = $true
        }
        else {
            throw
        }
    }
    Write-Host
    if ($needLogin) {

        Write-Host "Logging in..." -ForegroundColor Green
        Login-AzureRmAccount
    }
    else {
        Write-Host ("Already logged in as {0}" -f $content.Account) -ForegroundColor Green
    }
}