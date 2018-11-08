function Add-EventHub-Namespace {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Eventhub namespace.")]
        [String]$EventhubNamespace
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     EventHub Namespace Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host    

    $eventhubNamespaceDetail = (az eventhubs namespace list --resource-group $global:Resourcegroup | ConvertFrom-Json) | Where-Object {$_.name -eq $eventhubNamespace}

    if ([string]::IsNullOrEmpty($eventhubNamespaceDetail)) {
        Write-Host -ForegroundColor Green ("Creating eventhub namespace {0}" -f $eventhubNamespace)

        $Params = "--name", $eventhubNamespace,
        "--resource-group", $global:Resourcegroup,
        "--location", $global:AzureRegion,
        "--sku", "Standard"

        (az eventhubs namespace create `
                $Params `
                | ConvertFrom-Json) | Out-Null
    }
    else {
        Write-Host -ForegroundColor Green ("Eventhub namespace {0} already exists" -f $eventhubNamespace)
    }

}

function Add-Eventhub-Consumergroup {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Eventhub namespace.")]
        [String]$EventhubNamespace,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Eventhub name.")]
        [String]$EventhubName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Eventhub Consumergroup name.")]
        [String]$EventhubConsumerGroup
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     EventHub Consumergroup Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    $ReadParams = "--resource-group", $global:Resourcegroup,
    "--namespace-name", $EventhubNamespace,
    "--eventhub-name", $EventhubName

    $consumergroupDetail = (az eventhubs eventhub consumer-group list $ReadParams  | ConvertFrom-Json) | Where-Object {$_.name -eq $EventhubConsumerGroup}

    if (([string]::IsNullOrEmpty($consumergroupDetail))) {
        Write-Host -ForegroundColor Green ("Creating Eventhub Consumergroup {0}" -f $EventhubConsumerGroup)

        $Params = "--namespace-name", $EventhubNamespace,
        "--eventhub-name", $EventhubName,   
        "--name", $EventhubConsumerGroup,      
        "--resource-group", $global:Resourcegroup

        (az eventhubs eventhub consumer-group create `
                $Params `
                | ConvertFrom-Json) | Out-Null
    }
    else {
        Write-Host -ForegroundColor Green ("Eventhub Consumergroup {0} already exists" -f $EventhubConsumerGroup)
    }

}

function Add-EventHub {
    [CmdletBinding(DefaultParameterSetName='EventHub')]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Eventhub namespace.")]
        [String]$EventhubNamespace,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Eventhub name.")]
        [String]$EventhubName,
        [Parameter(Mandatory = $false, HelpMessage = "Enable/Disable Eventhub Capture.", ParameterSetName = "Capture")]
        [switch]$EnableCapture,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Storage Account name.", ParameterSetName = "Capture")]
        [String]$CaptureStorageAccountName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Storage Container name.", ParameterSetName = "Capture")]
        [String]$CaptureStorageContainerName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     EventHub Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    $ReadParams = "--resource-group", $global:Resourcegroup,
    "--namespace-name", $EventhubNamespace

    $eventhubDetail = (az eventhubs eventhub list $ReadParams  | ConvertFrom-Json) | Where-Object {$_.name -eq $eventhubName}

    if (([string]::IsNullOrEmpty($eventhubDetail.name))) {
        Write-Host -ForegroundColor Green ("Creating Eventhub {0}" -f $EventhubName)

        $Params = "--namespace-name", $EventhubNamespace,
        "--name", $EventhubName,        
        "--resource-group", $global:Resourcegroup

        if ($EnableCapture) {
            $Params += "--enable-capture", "true",
            "--storage-account", $CaptureStorageAccountName,
            "--blob-container", $CaptureStorageContainerName,
            "--partition-count", 2,
            "--capture-interval", 60,
            "--capture-size-limit", 30000000,
            "--destination-name", "EventHubArchive.AzureBlockBlob"
        }
        else {
            $Params += "--enable-capture", "false"
        }

        (az eventhubs eventhub create `
                $Params `
                | ConvertFrom-Json) | Out-Null
    }
    else {
        Write-Host -ForegroundColor Green ("Eventhub {0} already exists" -f $eventhubName)
    }
}
function Get-EventHub-ConnectionString {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Eventhub namespace.")]
        [String]$EventhubNamespace,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Eventhub name.")]
        [String]$EventhubName
    )

    $Params = "-g", $global:Resourcegroup,
    "--namespace-name", $eventhubNamespace,
    "-n", "RootManageSharedAccessKey"

    $eventHubDetail = (az eventhubs namespace authorization-rule keys list `
            $Params `
            | ConvertFrom-Json)

    if (![string]::IsNullOrEmpty($eventHubDetail)) {        
        return $eventHubDetail.primaryConnectionString
    }
    else {
        Write-Host -ForegroundColor Red ("Eventhub {0} connectionstring not found !!!!" -f $eventhubName)

        throw ("Eventhub {0} connectionstring not found !!!!" -f $eventhubName)
    }
}