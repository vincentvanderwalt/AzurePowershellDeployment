function Add-AppInsight-For-Web {
    Param(
        [String]$inputInsightName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     App Insight Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($inputInsightName)) {
        Do {
            $insightName = Read-Host "Please provide a app insight name"
        } While ([string]::IsNullOrEmpty($keyvaultName))
    }
    else {
        $insightName = $inputInsightName
    }

    $insightDetail = (az resource list --name $insightName | ConvertFrom-Json) | where {$_.name -eq $insightName -and $_.type -eq 'Microsoft.Insights/components'}

    if ([string]::IsNullOrEmpty($insightDetail)) {
        Write-Host -ForegroundColor Green ("Creating Application Insight {0}" -f $insightName)
        az resource create -g $Script:Resourcegroup -n $insightName --resource-type Microsoft.Insights/components --properties '{\"Application_Type\":\"web\",\"Flow_Type\":\"Redfield\",\"Request_Source\":\"AppServiceEnablementCreate\"}'    
    }
    else {
        Write-Host -ForegroundColor Green ("Application Insight {0} already exists" -f $insightName)
    }
}

function Get-AppInsight-InstrumentKey {
    Param(
        [String]$inputInsightName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     App Insight Key Retrieval"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($inputInsightName)) {
        Do {
            $insightName = Read-Host "Please provide a app insight name"
        } While ([string]::IsNullOrEmpty($keyvaultName))
    }
    else {
        $insightName = $inputInsightName
    }

    $insightKey = az resource show -g $Script:Resourcegroup -n $insightName --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey

    return $insightKey
}





