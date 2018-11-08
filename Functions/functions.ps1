function Add-FunctionApp-Using-App-Service {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Function App name.")]
        [String]$FunctionAppName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a App Service Plan name.")]
        [String]$AppServicePlanName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Storage Account name.")]
        [String]$StorageAccountName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###              Function App Creation on App Service"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    $functionAppDetail = (az functionapp list --resource-group $global:Resourcegroup | ConvertFrom-Json) | Where-Object {$_.name -eq $FunctionAppName}

    if ([string]::IsNullOrEmpty($functionAppDetail)) {
        Write-Host -ForegroundColor Green ("Creating Function app {0}" -f $FunctionAppName)

        $Params = "-n", $FunctionAppName,
        "-g", $global:Resourcegroup,
        "-p", $AppServicePlanName,
        "-s", $StorageAccountName

        (az functionapp create `
                $Params `
                | ConvertFrom-Json) | Out-Null
            
    }
    else {
        Write-Host -ForegroundColor Green ("Function app {0} already exists" -f $FunctionAppName)
    }
}

function Add-FunctionApp-Using-Consumption-Plan {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Function App name.")]
        [String]$FunctionAppName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Storage Account name.")]
        [String]$StorageAccountName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###              Function App Creation on Consumption"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host   

    $functionAppDetail = (az functionapp list -g $global:Resourcegroup | ConvertFrom-Json) | Where-Object {$_.name -eq $FunctionAppName}

    if ([string]::IsNullOrEmpty($functionAppDetail)) {
        Write-Host -ForegroundColor Green ("Creating Function app {0}" -f $FunctionAppName)

        $Params = "-n", $FunctionAppName,
        "-g", $global:Resourcegroup,
        "-c", $global:AzureRegion,
        "-s", $StorageAccountName

        (az functionapp create `
                $Params `
                | ConvertFrom-Json) | Out-Null
    }
    else {
        Write-Host -ForegroundColor Green ("Function app {0} already exists" -f $FunctionAppName)
    }
}

function Update-Function-Config {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Function App name.")]
        [String]$FunctionAppName
    )

    $Params = "--name", $FunctionAppName,
    "--resource-group", $global:Resourcegroup,
    "--use-32bit-worker-process", "false",
    "--php-version", "Off"

    (az functionapp config set $Params | ConvertFrom-Json) | Out-Null
}

function Enable-FunctionApp-Identity {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Function App name.")]
        [String]$FunctionAppName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     Function App Identity Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    $Params = "-g", $global:Resourcegroup,
    "-n", $functionAppName

    $functionAppIdentityDetail = (az functionapp identity show $Params | ConvertFrom-Json)

    if ([string]::IsNullOrEmpty($functionAppIdentityDetail)) {
        Write-Host -ForegroundColor Green ("Creating Function app identity {0}" -f $functionAppName)

        $funcIdentity = (az functionapp identity assign $Params| ConvertFrom-Json)
        return $funcIdentity.principalId
    }
    else {        
        Write-Host -ForegroundColor Green ("Function app identity {0} already exists" -f $functionAppName)
        return $functionAppIdentityDetail.principalId
    }
}

function Add-Function-Appsetting {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Function App name.")]
        [String]$FunctionAppName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Setting name.")]
        [String]$FunctionSettingName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Setting value.")]
        [String]$FunctionSettingValue
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     Function AppSetting Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    $ReadParams = "-n", $FunctionAppName,
    "-g", $global:Resourcegroup

    $appSettingDetail = (az functionapp config appsettings list $ReadParams | ConvertFrom-Json) | Where-Object {$_.name -eq $FunctionSettingName}

    if ([string]::IsNullOrEmpty($appSettingDetail)) {
        Write-Host -ForegroundColor Green ("Creating App Setting {0} in function {1}" -f $FunctionSettingName, $FunctionAppName)

        $Params = $ReadParams
        $Params += "--settings", "$FunctionSettingName=$FunctionSettingValue"
        
        (az functionapp config appsettings set $Params | ConvertFrom-Json) | Out-Null
    }
    else {
        Write-Host -ForegroundColor Green ("App Setting {0} already exists in function {1}" -f $FunctionSettingName, $FunctionAppName)
    }

}

function Get-Function-Key {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Function App name.")]
        [String]$FunctionAppName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Function name.")]
        [String]$FunctionName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                   Get Function Key"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    $Params = "-n", $FunctionAppName,
    "-g", $global:Resourcegroup,
    "--query", "[?publishMethod=='MSDeploy']",
    "-o", "json"
    
    $dep = az webapp deployment list-publishing-profiles `
    $Params `
         | ConvertFrom-Json;

    $username = $dep.userName;
    $pass = $dep.userPWD;

    $encoded = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("${username}:${pass}"));

    $masterResp = Invoke-RestMethod `
        -Uri "https://$functionAppName.scm.azurewebsites.net/api/functions/admin/masterkey" `
        -Headers @{"Authorization" = "Basic " + $encoded};

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # $HostResp = Invoke-RestMethod `
    #     -Uri "https://$functionAppName.azurewebsites.net/admin/host/keys?code=$($masterResp.masterKey)" `
    #     -Headers @{"Authorization" = "Basic " + $encoded};

    $FuncResp = Invoke-RestMethod `
        -Uri "https://$functionAppName.azurewebsites.net/admin/functions/$functionName/keys?code=$($masterResp.masterKey)" `
        -Headers @{"Authorization" = "Basic " + $encoded}; 

    return $FuncResp.keys[0].value

}

function Get-Function-Url {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Function App name.")]
        [String]$FunctionAppName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Function name.")]
        [String]$FunctionName
    )    

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                   Get Function Url"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    $Key = Get-Function-Key $FunctionAppName $FunctionName

    return "https://$($FunctionAppName).azurewebsites.net/api/$($FunctionName)?code=$($Key)"


}