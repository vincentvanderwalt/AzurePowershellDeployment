. ".\Functions\login.ps1"
. ".\Functions\subscription.ps1"
. ".\Functions\environment.ps1"
. ".\Functions\region.ps1"
. ".\Functions\resourcegroup.ps1"
. ".\Functions\keyvault.ps1"
. ".\Functions\blobstorage.ps1"
. ".\Functions\cosmosdb.ps1"

$Script:SubscriptionId = $null
$Script:ResourcePrefix = $null
$Script:AzureRegion = $null
$Script:Resourcegroup = $null

Login

Select-Subscription

Select-Environment "Dev"

Select-Region "ukwest"

Add-Resourcegroup "vinny-test"

Add-Keyvault "vinny-kv1"

# $storageName = Add-StorageAccount "vinny-sg" "Standard_LRS" "StorageV2"

# Add-StorageContainer $storageName "raw"

# Add-StorageContainer $storageName "staging-1"

# Add-StorageContainer $storageName "staging-2"

# Add-CosmosDb-Account "vinny-db"

