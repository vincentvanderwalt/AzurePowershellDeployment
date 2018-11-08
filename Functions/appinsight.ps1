function Add-AppInsight-For-Web {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Application Insight name.")]
        [String]$ApplicationInsightName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     App Insight Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    $AppInsightDetail = (az resource list --name $ApplicationInsightName | ConvertFrom-Json) | Where-Object {$_.name -eq $ApplicationInsightName -and $_.type -eq 'Microsoft.Insights/components'}

    if ([string]::IsNullOrEmpty($AppInsightDetail)) {
        Write-Host -ForegroundColor Green ("Creating Application Insight {0}" -f $ApplicationInsightName)

        $Params = "-g", $global:Resourcegroup, 
        "-n", $ApplicationInsightName,
        "--resource-type", "Microsoft.Insights/components",
        "--properties", '{\"Application_Type\":\"web\",\"Flow_Type\":\"Redfield\",\"Request_Source\":\"AppServiceEnablementCreate\"}'

       (az resource create $Params | ConvertFrom-Json) | Out-Null
    }
    else {
        Write-Host -ForegroundColor Green ("Application Insight {0} already exists" -f $ApplicationInsightName)
    }
}

function Get-AppInsight-InstrumentKey {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Application Insight name.")]
        [String]$ApplicationInsightName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     App Insight Key Retrieval"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    $Params = "-g", $global:Resourcegroup, 
    "-n", $ApplicationInsightName,
    "--resource-type", "Microsoft.Insights/components",
    "--query", "properties.InstrumentationKey"    

    $insightKey = az resource show $Params

    return $insightKey
}





