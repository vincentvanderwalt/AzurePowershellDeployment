
function Add-StorageAccount {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Storage Account name.")]
        [String]$StorageAccountName,       
        [String]$StorageAccountSku,
        [String]$StorageAccountKind
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                    Storage Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host
    

    $StorageAccountName = $StorageAccountName -replace '[^a-zA-Z0-9]', ''
    $StorageAccountName = $StorageAccountName.ToLowerInvariant()
    if ($StorageAccountName.Length -gt 24) {
        $StorageAccountName = $StorageAccountName.Substring(0, 24)
    }
    
    $SkuNames = @(
        [pscustomobject]@{id = "Standard_LRS"; description = "Locally-redundant"},  
        [pscustomobject]@{id = "Standard_ZRS"; description = "Zone-redundant"},
        [pscustomobject]@{id = "Standard_GRS"; description = "Geo-redundant"},
        [pscustomobject]@{id = "Standard_RAGRS"; description = "Read access geo-redundant"},  
        [pscustomobject]@{id = "Premium_LRS"; description = "Premium locally-redundant"}
    )

    if ([string]::IsNullOrEmpty($StorageAccountSku) -or !($SkuNames.id -contains $StorageAccountSku)) {
        $idx = -1
        Do {

            Write-Host "Please select a Sku for the storage account"
            Write-Host
            for ($i = 0; $i -lt $SkuNames.count; $i++) {
                Write-Host -ForegroundColor Cyan "  $($i+1)." $SkuNames[$i].description
            }

            Write-Host
            $idx = (Read-Host "Please enter a selection") -as [int]

        } While ((-not $idx) -or (0 -gt $idx))

        $StorageAccountSku = $SkuNames[$idx - 1].id
    }

    $KindNames = @(
        [pscustomobject]@{id = "Storage"; description = "General purpose Storage account"},  
        [pscustomobject]@{id = "StorageV2"; description = "General Purpose Version 2 (GPv2) Storage account"},
        [pscustomobject]@{id = "BlobStorage"; description = "Blob Storage account"}
    )

    if ([string]::IsNullOrEmpty($StorageAccountKind) -or !($KindNames.id -contains $StorageAccountKind)) {
        $idx = -1
        Do {

            Write-Host "Please select a Kind for the storage account"
            Write-Host
            for ($i = 0; $i -lt $KindNames.count; $i++) {
                Write-Host -ForegroundColor Cyan "  $($i+1)." $KindNames[$i].description
            }

            Write-Host
            $idx = (Read-Host "Please enter a selection") -as [int]

        } While ((-not $idx) -or (0 -gt $idx))

        $StorageAccountKind = $KindNames[$idx - 1].id
    }
   

    $accountDetail = (az storage account list --resource-group $global:Resourcegroup | ConvertFrom-Json) | Where-Object {$_.name -eq $StorageAccountName}

    if (([string]::IsNullOrEmpty($accountDetail.name))) {
        Write-Host -ForegroundColor Green ("Creating Storage Account {0}" -f $StorageAccountName)

        $Params = "--resource-group", $global:Resourcegroup,
        "--name", $StorageAccountName,
        "--location", $global:AzureRegion,
        "--sku", $StorageAccountSku,
        "--kind", $StorageAccountKind

        (az storage account create `
                $Params `
                | ConvertFrom-Json) | Out-Null
    }
    else {
        Write-Host -ForegroundColor Green ("Storage Account {0} already exists" -f $StorageAccountName)
    }

    return $StorageAccountName
}

function Get-StorageAccountKey {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Storage Account name.")]
        [String]$StorageAccountName
    )

    $Params = "--resource-group", $global:Resourcegroup,
    "--account-name", $StorageAccountName

    $Key1 = (az storage account keys list $Params  | ConvertFrom-Json) | Where-Object {$_.keyName -eq "key1"}

    return $Key1.value
}

function Get-StorageConnectionString {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Storage Account name.")]
        [String]$StorageAccountName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                   Get Storage Connectionstring"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host
    
    $Params = "--name", $StorageAccountName,
    "--key", "primary"

    $result = (az storage account show-connection-string `
            $Params `
            | ConvertFrom-Json)

    return $result.connectionString
}
function Add-StorageContainer {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Storage Account name.")]
        [String]$StorageAccountName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Storage Container name.")]
        [String]$StorageContainerName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                    Storage Container Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host
   

    $key = Get-StorageAccountKey $StorageAccountName

    $Params = "--name", $StorageContainerName,
    "--account-name", $StorageAccountName,
    "--account-key", $key
    
    $containerExists = (az storage container exists  `
            $Params `
            | ConvertFrom-Json)
        
    if (!$containerExists.exists) {
        Write-Host -ForegroundColor Green ("Creating Storage Container {0}" -f $StorageContainerName)

        (az storage container create `
                $Params `
                | ConvertFrom-Json) | Out-Null
    }
    else {
        Write-Host -ForegroundColor Green ("Storage Container {0} already exists" -f $StorageContainerName)
    }
}