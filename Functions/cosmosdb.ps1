function Add-Cosmos-Account {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Cosmos Account name.")]
        [String]$CosmosAccountName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                    CosmosDb Account Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host
  

    $exist = az cosmosdb check-name-exists --name $CosmosAccountName

    if (![System.Convert]::ToBoolean($exist)) {
        Write-Host -ForegroundColor Green ("Creating CosmosDb Account {0}" -f $CosmosAccountName)

        $Params = "--resource-group", $global:Resourcegroup,
        "--name", $CosmosAccountName,
        "--kind", "GlobalDocumentDB"

       (az cosmosdb create $Params | ConvertFrom-Json)  | Out-Null          

    }
    else {
        Write-Host -ForegroundColor Green ("CosmosDb Account {0} already exists" -f $CosmosAccountName)
    }
}

function Add-Cosmos-Database {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Cosmos Database name.")]
        [string]$CosmosDatabaseName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Cosmos Account name.")]
        [String]$CosmosAccountName
    )

    $ReadParams = "--resource-group-name", $global:Resourcegroup,
    "--name", $CosmosAccountName

    $CosmosDatabaseDetail = (az cosmosdb database list  $ReadParams | ConvertFrom-Json) | Where-Object {$_.id -eq $CosmosDatabaseName}

    if ([string]::IsNullOrEmpty($CosmosDatabaseDetail)) {
        Write-Host -ForegroundColor Green ("Creating Cosmos Database {0}" -f $CosmosDatabaseName)

        $Params = "--db-name", $CosmosDatabaseName,
        "--resource-group-name", $global:Resourcegroup,
        "--name", $CosmosAccountName

        (az cosmosdb database create `
                $Params `
                | ConvertFrom-Json) | Out-Null
    }
    else {
        Write-Host -ForegroundColor Green ("Cosmos Database {0} already exists" -f $CosmosDatabaseName)
    }

}

function Add-Cosmos-Collection {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Cosmos Collection name.")]
        [String]$CosmosCollectionName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Cosmos Account name.")]
        [String]$CosmosAccountName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Cosmos Database name.")]
        [string]$CosmosDatabaseName,
        [string]$CollectionPartitionKey
    )

    $ReadParams = "--resource-group-name", $global:Resourcegroup,
    "--name", $CosmosAccountName,
    "--db-name", $CosmosDatabaseName
    

    $CosmosCollectionDetail = (az cosmosdb collection list $ReadParams | ConvertFrom-Json) | Where-Object {$_.id -eq $CosmosCollectionName}

    if ([string]::IsNullOrEmpty($CosmosCollectionDetail)) {
        Write-Host -ForegroundColor Green ("Creating Cosmos Collection {0}" -f $CosmosCollectionName)

        $currentDir = Convert-Path .
        $templateJson = "$currentDir\Functions\cosmosindexingpolicy.json"

        $params = "--db-name" , $CosmosDatabaseName ,
        "--resource-group-name" , $global:Resourcegroup ,
        "--name" , $CosmosAccountName ,
        "--collection-name" , $CosmosCollectionName ,
        "--indexing-policy" , "@$templateJson" 

        if (![string]::IsNullOrEmpty($CollectionPartitionKey)) {
            $params += "--partition-key-path" , $CollectionPartitionKey
        }

        (az cosmosdb collection create $params | ConvertFrom-Json) | Out-Null
    }
    else {
        Write-Host -ForegroundColor Green ("Cosmos Collection {0} already exists" -f $CosmosCollectionName)
    }

}

function Get-Cosmos-ConnectionString {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Cosmos Account name.")]
        [String]$CosmosAccountName
    )

    # $Key = Get-Cosmos-PrimaryKey $AccountName

    return "https://$CosmosAccountName.documents.azure.com:443"

    # return ("AccountEndpoint=https://{0}.documents.azure.com:443/;AccountKey={1};" -f $AccountName,$Key)
}

function Get-Cosmos-PrimaryKey {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Cosmos Account name.")]
        [String]$CosmosAccountName
    )

    $params = "--resource-group", $global:Resourcegroup, "--name", $CosmosAccountName

    $keyDetails = (az cosmosdb list-keys $params | ConvertFrom-Json)

    return $keyDetails.primaryMasterKey
}