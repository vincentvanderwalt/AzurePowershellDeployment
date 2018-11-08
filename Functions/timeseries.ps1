function Add-TimeSeriesInsight {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Timeseries environment name.")]
        [String]$TimeSeriesEnvironmentName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Timeseries eventsource name.")]
        [String]$TimeSeriesEventSourceName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Eventhub namespace.")]
        [String]$EventhubNamespace,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Eventhub name.")]
        [String]$EventhubName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Eventhub consumer group.")]
        [String]$EventhubConsumerGroup
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     TimeSeries Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    $ReadParams = "--resource-group", $global:Resourcegroup,
    "--name", $TimeSeriesEnvironmentName,
    "--resource-type", "Microsoft.TimeSeriesInsights/environments"

    $timeSeriesDetail = (az resource list $ReadParams | ConvertFrom-Json)|Where-Object {$_.name -eq $TimeSeriesEnvironmentName}

    if ([string]::IsNullOrEmpty($timeSeriesDetail)) {
        Write-Host -ForegroundColor Green ("Creating Timeseries environment {0}" -f $TimeSeriesEnvironmentName)

        $currentDir = Convert-Path .
        $templateDir = "$currentDir\Functions\timeseriesDeploy.json"

        $Params = "--resource-group", $global:Resourcegroup,
        "--template-file", $templateDir,
        "--parameters", "eventHubNamespaceName=$EventhubNamespace",
        "--parameters", "eventHubName=$EventhubName",
        "--parameters", "consumerGroupName=$EventhubConsumerGroup",
        "--parameters", "environmentName=$TimeSeriesEnvironmentName",
        "--parameters", "eventSourceName=$TimeSeriesEventSourceName"
        
        (az group deployment create $Params | ConvertFrom-Json)

    }
    else {
        Write-Host -ForegroundColor Green ("Timeseries environment {0} already exists" -f $TimeSeriesEnvironmentName)
    }
}