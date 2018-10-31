function Add-CosmosDb-Account {
    Param(
        [String]$inputName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                    CosmosDb Account Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($inputName)) {
        Do {
            $Name = Read-Host "Please provide a CosmosDb Account name"
        } While ([string]::IsNullOrEmpty($Name))
    }
    else {
        $Name = $inputName
    }

    if (![string]::IsNullOrEmpty($Script:ResourcePrefix)) {
        $Name = ("{0}-{1}" -f $Script:ResourcePrefix, $Name) 
    }

    $cosmosDb = Get-AzureRmResource -ResourceType "Microsoft.DocumentDb/databaseAccounts" `
    -ApiVersion "2015-04-08" `
    -ResourceGroupName $Script:Resourcegroup `
    -Name $Name

    if (([string]::IsNullOrEmpty($cosmosDb))) {
        $consistencyPolicy = @{"defaultConsistencyLevel" = "Session"; "maxIntervalInSeconds" = "5"; "maxStalenessPrefix" = "100"}
        $CosmosDBProperties = @{"databaseAccountOfferType" = "Standard"; 
            "consistencyPolicy"                            = $consistencyPolicy;
        }
        Write-Host -ForegroundColor Green ("Creating CosmosDb Account {0}" -f $Name)

        New-AzureRmResource -ResourceType "Microsoft.DocumentDb/databaseAccounts" `
            -ApiVersion "2015-04-08" `
            -ResourceGroupName $Script:Resourcegroup  `
            -Location $Script:AzureRegion `
            -Name $Name `
            -Properties $CosmosDBProperties
    } else {
        Write-Host -ForegroundColor Green ("CosmosDb Account {0} already exists" -f $Name)
    }

    Write-Host
   
}