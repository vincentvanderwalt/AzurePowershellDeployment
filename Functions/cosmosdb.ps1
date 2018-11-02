function Add-Cosmos-Account {
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

    $exist = az cosmosdb check-name-exists --name $Name

    if (![System.Convert]::ToBoolean($exist)) {
        Write-Host -ForegroundColor Green ("Creating CosmosDb Account {0}" -f $Name)
        az cosmosdb create `
        --resource-group $Script:Resourcegroup `
        --name $Name `
        --kind "GlobalDocumentDB"

    }
    else {
        Write-Host -ForegroundColor Green ("CosmosDb Account {0} already exists" -f $Name)
    }
    return $Name
}

function Add-Cosmos-Database {
    Param(
        [String]$inputName,
        [String]$inputCosmosAccountName
    )

    if ([string]::IsNullOrEmpty($inputName)) {
        Do {
            $Name = Read-Host "Please provide a CosmosDb Database name"
        } While ([string]::IsNullOrEmpty($Name))
    }
    else {
        $Name = $inputName
    }

    if ([string]::IsNullOrEmpty($inputCosmosAccountName)) {
        Do {
            $AccountName = Read-Host "Please provide a CosmosDb Account name"
        } While ([string]::IsNullOrEmpty($AccountName))
    }
    else {
        $AccountName = $inputCosmosAccountName
    }

    $cosmosDatabaseDetail = (az cosmosdb database list --resource-group-name $Script:Resourcegroup --name $AccountName | ConvertFrom-Json) | where {$_.id -eq $Name}

    if ([string]::IsNullOrEmpty($cosmosDatabaseDetail)) {
        Write-Host -ForegroundColor Green ("Creating Cosmos Database {0}" -f $Name)
        az cosmosdb database create --db-name $Name --resource-group-name $Script:Resourcegroup --name $AccountName 
    }
    else {
        Write-Host -ForegroundColor Green ("Cosmos Database {0} already exists" -f $Name)
    }

}

function Add-Cosmos-Collection {
    Param(
        [String]$inputName,
        [String]$inputCosmosAccountName,
        [string]$inputCosmosDbName
    )

    if ([string]::IsNullOrEmpty($inputName)) {
        Do {
            $Name = Read-Host "Please provide a Cosmos Collection name"
        } While ([string]::IsNullOrEmpty($Name))
    }
    else {
        $Name = $inputName
    }

    if ([string]::IsNullOrEmpty($inputCosmosAccountName)) {
        Do {
            $cosmosAccountName = Read-Host "Please provide a Cosmos Account name"
        } While ([string]::IsNullOrEmpty($cosmosAccountName))
    }
    else {
        $cosmosAccountName = $inputCosmosAccountName
    }

    if ([string]::IsNullOrEmpty($inputCosmosDbName)) {
        Do {
            $cosmosDatabaseName = Read-Host "Please provide a Cosmos Database name"
        } While ([string]::IsNullOrEmpty($cosmosDatabaseName))
    }
    else {
        $cosmosDatabaseName = $inputCosmosDbName
    }

    $cosmosCollectionDetail = (az cosmosdb collection list --resource-group-name $Script:Resourcegroup --name $cosmosAccountName --db-name $cosmosDatabaseName | ConvertFrom-Json) | where {$_.id -eq $Name}

    if ([string]::IsNullOrEmpty($cosmosCollectionDetail)) {
        Write-Host -ForegroundColor Green ("Creating Cosmos Collection {0}" -f $Name)
        az cosmosdb collection create --db-name $cosmosDatabaseName --resource-group-name $Script:Resourcegroup --name $cosmosAccountName --collection-name $Name
    }
    else {
        Write-Host -ForegroundColor Green ("Cosmos Collection {0} already exists" -f $Name)
    }

}

function Get-Cosmos-ConnectionString {
    Param(
        [String]$inputAccountName
    )

    if ([string]::IsNullOrEmpty($inputAccountName)) {
        Do {
            $AccountName = Read-Host "Please provide a CosmosDb Account name to retrieve connectionstring for"
        } While ([string]::IsNullOrEmpty($AccountName))
    }
    else {
        $AccountName = $inputAccountName
    }

    $Key = Get-Cosmos-PrimaryKey $AccountName

    return ("AccountEndpoint=https://{0}.documents.azure.com:443/;AccountKey={1};" -f $AccountName,$Key)
}

function Get-Cosmos-PrimaryKey {
    Param(
        [String]$inputAccountName
    )

    if ([string]::IsNullOrEmpty($inputAccountName)) {
        Do {
            $AccountName = Read-Host "Please provide a CosmosDb Account name to retrieve connectionstring for"
        } While ([string]::IsNullOrEmpty($AccountName))
    }
    else {
        $AccountName = $inputAccountName
    }

    $keyDetails = (az cosmosdb list-keys --resource-group $Script:Resourcegroup --name $AccountName | ConvertFrom-Json)

    return $keyDetails.primaryMasterKey
}