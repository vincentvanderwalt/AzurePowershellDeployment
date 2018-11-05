function Add-Resourcegroup {
    Param(
        [String]$inputResourcegroup
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                   Resourcegroup Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host
    
    if ([string]::IsNullOrEmpty($inputResourcegroup)) {
        Do {
            $resourcegroupName = Read-Host "Please provide a resourcegroup name"
        } While ([string]::IsNullOrEmpty($resourcegroupName))
    }
    else {
        $resourcegroupName = $inputResourcegroup
    }

    $resourcegroupName = $resourcegroupName.ToLowerInvariant()

    $resourcegroupExists = az group exists --name $resourcegroupName

    $resourcegroupExists = [System.Convert]::ToBoolean($resourcegroupExists)

    if (!$resourcegroupExists) {
        Write-Host -ForegroundColor Green ("Creating Resource group {0}" -f $resourcegroupName)
        az group create --name $resourcegroupName --location $Script:AzureRegion
    }
    else {
        Write-Host -ForegroundColor Green ("Resource group {0} already exists" -f $resourcegroupName)
    }

    return $resourcegroupName
}