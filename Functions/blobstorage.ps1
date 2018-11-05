
function Add-StorageAccount {
    Param(
        [String]$inputName,
        [String]$inputSku,
        [String]$inputKind
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                    Storage Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    Write-Host
    if ([string]::IsNullOrEmpty($inputName)) {
        Do {
            $Name = Read-Host "Please provide a Storage Account name"
        } While ([string]::IsNullOrEmpty($Name))
    }
    else {
        $Name = $inputName
    }

    $Name = $Name -replace '[^a-zA-Z0-9]', ''
    $Name = $Name.ToLowerInvariant()
    if ($Name.Length -gt 24) {
        $Name = $Name.Substring(0, 24)
    }
    
    $SkuNames = @(
        [pscustomobject]@{id = "Standard_LRS"; description = "Locally-redundant"},  
        [pscustomobject]@{id = "Standard_ZRS"; description = "Zone-redundant"},
        [pscustomobject]@{id = "Standard_GRS"; description = "Geo-redundant"},
        [pscustomobject]@{id = "Standard_RAGRS"; description = "Read access geo-redundant"},  
        [pscustomobject]@{id = "Premium_LRS"; description = "Premium locally-redundant"}
    )

    if ([string]::IsNullOrEmpty($inputSku)) {
        $idx = -1
        Do {

            Write-Host
            for ($i = 0; $i -lt $SkuNames.count; $i++) {
                Write-Host -ForegroundColor Cyan "  $($i+1)." $SkuNames[$i].description
            }

            Write-Host
            $idx = (Read-Host "Please enter a selection") -as [int]

        } While ((-not $idx) -or (0 -gt $idx))

        $Sku = $SkuNames[$idx - 1].id
    }
    else {
        $Sku = $inputSku
    }

    $KindNames = @(
        [pscustomobject]@{id = "Storage"; description = "General purpose Storage account"},  
        [pscustomobject]@{id = "StorageV2"; description = "General Purpose Version 2 (GPv2) Storage account"},
        [pscustomobject]@{id = "BlobStorage"; description = "Blob Storage account"}
    )

    if ([string]::IsNullOrEmpty($inputKind)) {
        $idx = -1
        Do {

            Write-Host
            for ($i = 0; $i -lt $KindNames.count; $i++) {
                Write-Host -ForegroundColor Cyan "  $($i+1)." $KindNames[$i].description
            }

            Write-Host
            $idx = (Read-Host "Please enter a selection") -as [int]

        } While ((-not $idx) -or (0 -gt $idx))

        $Kind = $KindNames[$idx - 1].id
    }
    else {
        $Kind = $inputKind
    }

    $accountDetail = (az storage account list --resource-group $Script:Resourcegroup | ConvertFrom-Json) | where {$_.name -eq $Name}

    if (([string]::IsNullOrEmpty($accountDetail.name))) {
        Write-Host -ForegroundColor Green ("Creating Storage Account {0}" -f $Name)

        az storage account create --resource-group $Script:Resourcegroup `
        --name $Name `
        --location  $Script:AzureRegion `
        --sku $Sku `
        --kind $Kind
    }
    else {
        Write-Host -ForegroundColor Green ("Storage Account {0} already exists" -f $Name)
    }

    return $Name
}

function Get-StorageKey {
    Param(
        [String]$inputStorageAccount
    )

    if ([string]::IsNullOrEmpty($inputStorageAccount)) {
        Do {
            $storageAccount = Read-Host "Please provide a Storage Account name"
        } While ([string]::IsNullOrEmpty($storageAccount))
    }
    else {
        $storageAccount = $inputStorageAccount
    }

    $Key1 = (az storage account keys list --account-name $storageAccount --resource-group $Script:Resourcegroup| ConvertFrom-Json) | where {$_.keyName -eq "key1"}

    return $Key1.value

}

function Get-StorageConnectionString {
    Param(
        [String]$inputStorageAccount
    )

    if ([string]::IsNullOrEmpty($inputStorageAccount)) {
        Do {
            $storageAccount = Read-Host "Please provide a Storage Account name"
        } While ([string]::IsNullOrEmpty($storageAccount))
    }
    else {
        $storageAccount = $inputStorageAccount
    }

    $result = (az storage account show-connection-string `
    --name $storageAccount `
    --key primary `
    | ConvertFrom-Json)

    return $result.connectionString
}
function Add-StorageContainer {
    Param(
        [String]$inputStorageAccount,
        [String]$inputName        
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                    Storage Container Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($inputStorageAccount)) {
        Do {
            $storageAccount = Read-Host "Please provide a Storage Account name"
        } While ([string]::IsNullOrEmpty($storageAccount))
    }
    else {
        $storageAccount = $inputStorageAccount
    }

    if ([string]::IsNullOrEmpty($inputName)) {
        Do {
            $containerName = Read-Host "Please provide a Container name"
        } While ([string]::IsNullOrEmpty($containerName))
    }
    else {
        $containerName = $inputName
    }

    $key = Get-StorageKey $storageAccount
    
    $containerExists = (az storage container exists --name $containerName `
    --account-name $storageAccount `
    --account-key $key `
    | ConvertFrom-Json)
        
    if (!$containerExists.exists) {
        Write-Host -ForegroundColor Green ("Creating Storage Container {0}" -f $containerName)

        az storage container create --name $containerName `
        --account-name $storageAccount `
        --account-key $key
    }
    else {
        Write-Host -ForegroundColor Green ("Storage Container {0} already exists" -f $containerName)
    }
}