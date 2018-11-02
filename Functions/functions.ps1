function Add-FunctionApp {
    Param(
        [String]$inputName,
        [String]$inputPlanName,
        [String]$inputAppStorage
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     Function App Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($inputName)) {
        Do {
            $functionAppName = Read-Host "Please provide a function app name"
        } While ([string]::IsNullOrEmpty($functionAppName))
    }
    else {
        $functionAppName = $inputName
    }

    if ([string]::IsNullOrEmpty($inputPlanName)) {
        Do {
            $appPlanName = Read-Host "Please provide a function app service plan name"
        } While ([string]::IsNullOrEmpty($appPlanName))
    }
    else {
        $appPlanName = $inputPlanName
    }

    if ([string]::IsNullOrEmpty($inputAppStorage)) {
        Do {
            $appStorageName = Read-Host "Please provide a function app storage account name"
        } While ([string]::IsNullOrEmpty($appStorageName))
    }
    else {
        $appStorageName = $inputAppStorage
    }

    $functionAppDetail = (az functionapp list --resource-group $Script:Resourcegroup | ConvertFrom-Json) | where {$_.name -eq $functionAppName}

    if ([string]::IsNullOrEmpty($functionAppDetail)) {
        Write-Host -ForegroundColor Green ("Creating Function app {0}" -f $functionAppName)

        az functionapp create `
            --name $functionAppName `
            --resource-group $Script:Resourcegroup `
            --plan $appPlanName `
            -s $appStorageName
    }
    else {
        Write-Host -ForegroundColor Green ("Function app {0} already exists" -f $functionAppName)
    }
}

function Enable-FunctionApp-Identity {
    Param(
        [String]$inputAppName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     Function App Identity Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($inputAppName)) {
        Do {
            $functionAppName = Read-Host "Please provide a function app name"
        } While ([string]::IsNullOrEmpty($functionAppName))
    }
    else {
        $functionAppName = $inputAppName
    }
    

    $functionAppIdentityDetail = (az functionapp identity show -g $Script:Resourcegroup -n $functionAppName | ConvertFrom-Json)

    if ([string]::IsNullOrEmpty($functionAppIdentityDetail)) {
        Write-Host -ForegroundColor Green ("Creating Function app identity {0}" -f $functionAppName)

        $funcIdentity = (az functionapp identity assign -g $Script:Resourcegroup -n $functionAppName | ConvertFrom-Json)
        return $funcIdentity.principalId
    }
    else {        
        Write-Host -ForegroundColor Green ("Function app identity {0} already exists" -f $functionAppName)
        return $functionAppIdentityDetail.principalId
    }
}

function Add-Function-Appsetting {
    Param(
        [String]$inputFunctionName,
        [String]$inputSettingName,
        [String]$inputSettingValue
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     Function AppSetting Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($inputFunctionName)) {
        Do {
            $functionName = Read-Host "Please provide a function name"
        } While ([string]::IsNullOrEmpty($functionName))
    }
    else {
        $functionName = $inputFunctionName
    }

    if ([string]::IsNullOrEmpty($inputSettingName)) {
        Do {
            $functionSettingName = Read-Host "Please provide a function appsetting name"
        } While ([string]::IsNullOrEmpty($functionAppName))
    }
    else {
        $functionSettingName = $inputSettingName
    }

    if ([string]::IsNullOrEmpty($inputSettingValue)) {
        Do {
            $functionSettingValue = Read-Host "Please provide a function appsetting value"
        } While ([string]::IsNullOrEmpty($functionSettingValue))
    }
    else {
        $functionSettingValue = $inputSettingValue
    }

    $appSettingDetail = (az functionapp config appsettings list -n $functionName -g $Script:Resourcegroup | ConvertFrom-Json) | where {$_.name -eq $functionSettingName}

    if ([string]::IsNullOrEmpty($appSettingDetail)) {
        Write-Host -ForegroundColor Green ("Creating App Setting {0} in function {1}" -f $functionSettingName, $functionName)
        
        az functionapp config appsettings set -n $functionName `
            -g $Script:Resourcegroup `
            --settings $functionSettingName=$functionSettingValue
    }
    else {
        Write-Host -ForegroundColor Green ("App Setting {0} already exists in function {1}" -f $functionSettingName, $functionName)
    }

}