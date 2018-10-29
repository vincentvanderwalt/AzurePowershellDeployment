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

    if (![string]::IsNullOrEmpty($Script:ResourcePrefix)) {
        $resourcegroupName = ("{0}-{1}" -f $Script:ResourcePrefix,$resourcegroupName) 
    }

    Get-AzureRmResourceGroup -Name $resourcegroupName -ErrorVariable resourcegroupNotPresent -ErrorAction SilentlyContinue | Out-Null

    if ($resourcegroupNotPresent) {
        Write-Host -ForegroundColor Green ("Creating Resource group {0}" -f $resourcegroupName)
        New-AzureRmResourceGroup -Name $resourcegroupName -Location $Script:AzureRegion
    }
    else {
        Write-Host -ForegroundColor Green ("Resource group {0} already exists" -f $resourcegroupName)
    }

    $Script:Resourcegroup = $resourcegroupName
}