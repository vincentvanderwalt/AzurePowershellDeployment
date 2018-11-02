function Add-EventHub-Namespace {
    Param(
        [String]$inputEventHubNamespace
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     EventHub Namespace Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($inputEventHubNamespace)) {
        Do {
            $eventhubNamespace = Read-Host "Please provide a eventhub namespace"
        } While ([string]::IsNullOrEmpty($eventhubNamespace))
    }
    else {
        $eventhubNamespace = $inputEventHubNamespace
    }

    $eventhubNamespace = $eventhubNamespace.ToLowerInvariant()

    if (![string]::IsNullOrEmpty($Script:ResourcePrefix)) {
        $eventhubNamespace = ("{0}-{1}" -f $Script:ResourcePrefix, $eventhubNamespace) 
    }

    $eventhubNamespaceDetail = (az eventhubs namespace list --resource-group $Script:Resourcegroup | ConvertFrom-Json) | where {$_.name -eq $eventhubNamespace}

    if ([string]::IsNullOrEmpty($eventhubNamespaceDetail)) {
        Write-Host -ForegroundColor Green ("Creating eventhub namespace {0}" -f $eventhubNamespace)
        az eventhubs namespace create `
            --name $eventhubNamespace `
            --resource-group $Script:Resourcegroup `
            --location $Script:AzureRegion `
            --sku "Standard"
    }
    else {
        Write-Host -ForegroundColor Green ("Eventhub namespace {0} already exists" -f $Script:eventhubNamespace)
    }

}

function Add-EventHub {
    Param(
        [String]$inputEventHubNamespace,
        [String]$inputEventHubName,
        [String]$inputEnableCapture,
        [String]$inputCaptureStorageAccount,
        [String]$inputCaptureStorageContainer
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     EventHub Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($inputEventHubNamespace)) {
        Do {
            $eventhubNamespace = Read-Host "Please provide a eventhub namespace"
        } While ([string]::IsNullOrEmpty($eventhubNamespace))
    }
    else {
        $eventhubNamespace = $inputEventHubNamespace
    }

    if ([string]::IsNullOrEmpty($inputEventHubName)) {
        Do {
            $eventhubName = Read-Host "Please provide a eventhub name"
        } While ([string]::IsNullOrEmpty($eventhubName))
    }
    else {
        $eventhubName = $inputEventHubName
    }

    $captureEnabled = $false
    if (![string]::IsNullOrEmpty($inputEnableCapture) -and [System.Convert]::ToBoolean($inputEnableCapture)) {
        $captureEnabled = $true
        if ([string]::IsNullOrEmpty($inputCaptureStorageAccount)) {
            Do {
                $captureStorageAccount = Read-Host "Please provide a storage account name for the capture"
            } While ([string]::IsNullOrEmpty($captureStorageAccount))
        }
        else {
            $captureStorageAccount = $inputCaptureStorageAccount
        }

        if ([string]::IsNullOrEmpty($inputCaptureStorageContainer)) {
            Do {
                $captureStorageContainer = Read-Host "Please provide a storage container for the capture"
            } While ([string]::IsNullOrEmpty($captureStorageContainer))
        }
        else {
            $captureStorageContainer = $inputCaptureStorageContainer
        }
    } 

    $eventhubDetail = (az eventhubs eventhub list --resource-group $Script:Resourcegroup --namespace-name $eventhubNamespace | ConvertFrom-Json) | where {$_.name -eq $eventhubName}

    if (([string]::IsNullOrEmpty($eventhubDetail.name))) {
        Write-Host -ForegroundColor Green ("Creating Eventhub {0}" -f $eventhubName)

        if ($captureEnabled) {
            az eventhubs eventhub create `
                --namespace-name $eventhubNamespace `
                --name $eventhubName `
                --enable-capture true `
                --resource-group $Script:Resourcegroup `
                --storage-account $captureStorageAccount `
                --blob-container $captureStorageContainer `
                --partition-count 2 `
                --capture-interval 60 `
                --capture-size-limit 30000000 `
                --destination-name "EventHubArchive.AzureBlockBlob"
        }
        else {
            az eventhubs eventhub create `
                --namespace-name $eventhubNamespace `
                --name $eventhubName `
                --enable-capture false `
                --resource-group $Script:Resourcegroup
        }
    }
    else {
        Write-Host -ForegroundColor Green ("Eventhub {0} already exists" -f $eventhubName)
    }
}


function Get-EventHub-ConnectionString {
    Param(
        [String]$inputEventHubNamespace,
        [String]$inputEventHubName
    )

    if ([string]::IsNullOrEmpty($inputEventHubNamespace)) {
        Do {
            $eventhubNamespace = Read-Host "Please provide a eventhub namespace"
        } While ([string]::IsNullOrEmpty($eventhubNamespace))
    }
    else {
        $eventhubNamespace = $inputEventHubNamespace
    }

    if ([string]::IsNullOrEmpty($inputEventHubName)) {
        Do {
            $eventhubName = Read-Host "Please provide a eventhub name"
        } While ([string]::IsNullOrEmpty($eventhubName))
    }
    else {
        $eventhubName = $inputEventHubName
    }

    $eventHubDetail = (az eventhubs namespace authorization-rule keys list `
            -g $Script:Resourcegroup `
            --namespace-name $eventhubNamespace `
            -n "RootManageSharedAccessKey" `
            | ConvertFrom-Json)

    if (![string]::IsNullOrEmpty($eventHubDetail)) {        
        return $eventHubDetail.primaryConnectionString
    }
    else {
        Write-Host -ForegroundColor Red ("Eventhub {0} connectionstring not found !!!!" -f $eventhubName)

        throw ("Eventhub {0} connectionstring not found !!!!" -f $eventhubName)
    }
}