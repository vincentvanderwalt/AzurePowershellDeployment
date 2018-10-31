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

    if (![string]::IsNullOrEmpty($Script:ResourcePrefix)) {
        $Name = ("{0}{1}" -f $Script:ResourcePrefix, $Name) 
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

    $accountDetail = Get-AzureRmStorageAccount -ResourceGroupName $Script:Resourcegroup -AccountName $Name

    if (([string]::IsNullOrEmpty($accountDetail.StorageAccountName))) {
        Write-Host -ForegroundColor Green ("Creating Storage Account {0}" -f $Name)
        $storageAccount = New-AzureRmStorageAccount -ResourceGroupName $Script:Resourcegroup `
        -Name $Name `
        -Location $Script:AzureRegion `
        -SkuName $Sku `
        -Kind $Kind
    }
    else {
        Write-Host -ForegroundColor Green ("Storage Account {0} already exists" -f $Name)
    }

    return $Name
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

    $containerDetail = Get-AzureRmStorageContainer -ResourceGroupName $Script:Resourcegroup -AccountName $storageAccount -ContainerName $containerName
    
    if (([string]::IsNullOrEmpty($containerDetail.Name))) {
        Write-Host -ForegroundColor Green ("Creating Storage Container {0}" -f $containerName)
        New-AzureRmStorageContainer -ResourceGroupName $Script:Resourcegroup `
        -AccountName $storageAccount `
        -ContainerName $containerName
    }
    else {
        Write-Host -ForegroundColor Green ("Storage Container {0} already exists" -f $containerName)
    }

    

}