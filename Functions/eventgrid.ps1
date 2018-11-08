function Enable-Webhook-Eventgrid-On-StorageAccount {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Eventgrid name.")]
        [String]$EventgridName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Storage Account name.")]
        [String]$StorageAccountName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a web endpoint.")]
        [String]$WebEndpoint,
        [String]$SubjectBeginsWithFilter,
        [String]$SubjectEndsWithFilter
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###              Eventgrid Creation on Storage Account "
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    $ResourceId = "/subscriptions/$global:SubscriptionId/resourceGroups/$global:Resourcegroup/providers/Microsoft.Storage/storageaccounts/$StorageAccountName"

    $ReadParams = "--resource-id", $ResourceId

    $EventGridDetail = (az eventgrid event-subscription list $ReadParams | ConvertFrom-Json) | Where-Object {$_.name -eq $EventgridName}

    if ([string]::IsNullOrEmpty($EventGridDetail)) {
        Write-Host -ForegroundColor Green ("Creating Eventgrid {0}" -f $EventgridName)

        $Params = "-g", $global:Resourcegroup,
        "-n", $EventgridName,
        "--resource-id", $ResourceId,
        "--endpoint", $WebEndpoint,
        "--included-event-types", "Microsoft.Storage.BlobCreated"

        if (![string]::IsNullOrEmpty($SubjectBeginsWithFilter)) {
            $Params += "--subject-begins-with", $SubjectBeginsWithFilter
        }
        
        if (![string]::IsNullOrEmpty($SubjectEndsWithFilter)) {
            $Params += "--subject-ends-with", $SubjectEndsWithFilter
        }        

        (az eventgrid event-subscription create `
                $Params `
                | ConvertFrom-Json) | Out-Null
    }
    else {
        Write-Host -ForegroundColor Green ("Eventgrid {0} already exists" -f $EventgridName)
    }

}
