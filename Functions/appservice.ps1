function Add-AppServicePlan {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a App Service Plan name.")]
        [String]$AppServicePlanName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     App Service Plan Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    $appServicePlanDetail = (az appservice plan list --resource-group $global:Resourcegroup | ConvertFrom-Json) | Where-Object {$_.name -eq $AppServicePlanName}

    if ([string]::IsNullOrEmpty($appServicePlanDetail)) {
        Write-Host -ForegroundColor Green ("Creating AppService Plan {0}" -f $AppServicePlanName)

        $Params = "--resource-group", $global:Resourcegroup,
        "--name", $AppServicePlanName,
        "--location", $global:AzureRegion,
        "--sku", "S1"

        (az appservice plan create `
                $Params `
                | ConvertFrom-Json)
    }
    else {
        Write-Host -ForegroundColor Green ("Appservice Plan {0} already exists" -f $AppServicePlanName)
    }
}