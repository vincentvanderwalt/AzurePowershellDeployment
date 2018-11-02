function Add-AppServicePlan {
    Param(
        [String]$inputPlanName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     App Service Plan Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($inputPlanName)) {
        Do {
            $planName = Read-Host "Please provide a appservice plan name"
        } While ([string]::IsNullOrEmpty($planName))
    }
    else {
        $planName = $inputPlanName
    }

    if (![string]::IsNullOrEmpty($Script:ResourcePrefix)) {
        $planName = ("{0}-{1}" -f $Script:ResourcePrefix, $planName) 
    }

    $appServicePlanDetail = (az appservice plan list --resource-group $Script:Resourcegroup | ConvertFrom-Json) | where {$_.name -eq $planName}

    if ([string]::IsNullOrEmpty($appServicePlanDetail)) {
        Write-Host -ForegroundColor Green ("Creating AppService Plan {0}" -f $planName)
        az appservice plan create `
        --name $planName `
        --resource-group $Script:Resourcegroup `
        --location $Script:AzureRegion `
        --sku "S1"
    }
    else {
        Write-Host -ForegroundColor Green ("Appservice Plan {0} already exists" -f $planName)
    }
}