. ".\Functions\login.ps1"
. ".\Functions\subscription.ps1"
. ".\Functions\prefix.ps1"
. ".\Functions\region.ps1"
. ".\Functions\resourcegroup.ps1"
. ".\Functions\keyvault.ps1"
. ".\Functions\blobstorage.ps1"
. ".\Functions\cosmosdb.ps1"
. ".\Functions\eventhub.ps1"
. ".\Functions\appservice.ps1"
. ".\Functions\functions.ps1"
. ".\Functions\appinsight.ps1"

Login

Select-Subscription "your-subscription-id"

# Select-Prefix "MyPlant"

Select-Region "eastus"

Add-Resourcegroup "myplant-dev-v2"

# Add-Keyvault "myplant-dev-v2-kv"

# $stagingSg = Add-StorageAccount "myplant-staging-v2-sg" "Standard_LRS" "StorageV2"

# Add-StorageContainer $stagingSg "raw"

# Add-StorageContainer $stagingSg "staging-alarms"

# Add-StorageContainer $stagingSg "staging-sensors"

# $stagingSgConn = Get-StorageConnectionString $stagingSg

# Add-Keyvault-Secret "AlarmManagement-Storage-Staging-Alarms-ConnectionString" $stagingSgConn

# Add-Keyvault-Secret "AlarmManagement-Storage-Staging-Alarms-Container-Name" "staging-alarms"

# Add-Keyvault-Secret "AlarmManagement-Storage-Staging-Sensors-ConnectionString" $stagingSgConn

# Add-Keyvault-Secret "AlarmManagement-Storage-Staging-Sensors-Container-Name" "staging-sensors"

# Add-EventHub-Namespace "myplant-dev-v2-ehns"

# Add-EventHub "myplant-dev-v2-ehns" "myplant-eh-1" "true" "myplantstagingv2sg" "raw"

# $EHConnectionString = Get-EventHub-ConnectionString "myplant-dev-v2-ehns" "myplant-eh-1"

# Add-Keyvault-Secret "AlarmManagement-EventHub-Name" "myplant-eh-1"

# Add-Keyvault-Secret "AlarmManagement-EventHub-ConnectionString" $EHConnectionString

# Add-EventHub-Namespace "myplant-dev-v2-tsns"

# Add-EventHub "myplant-dev-v2-tsns" "myplant-ts-1" "false"

# $TSConnectionString = Get-EventHub-ConnectionString "myplant-dev-v2-tsns" "myplant-ts-1"

# Add-Keyvault-Secret "AlarmManagement-TimeSeries-EventHub-Name" "myplant-dev-v2-tsns"

# Add-Keyvault-Secret "AlarmManagement-TimeSeries-EventHub-ConnectionString" $TSConnectionString

# $cosmosAccountName = Add-Cosmos-Account "myplant-dev-v2-db"

# Add-Cosmos-Database "myplant" $cosmosAccountName

# Add-Cosmos-Collection "alarms" $cosmosAccountName "myplant"

# Add-Cosmos-Collection "sensors" $cosmosAccountName "myplant"

# $cosmosConnectionString = Get-Cosmos-ConnectionString $cosmosAccountName

# $cosmosKey = Get-Cosmos-PrimaryKey $cosmosAccountName

# Add-Keyvault-Secret "AlarmManagement-CosmosDb-Endpoint" $cosmosConnectionString

# Add-Keyvault-Secret "AlarmManagement-CosmosDb-Key" $cosmosKey

# Add-Keyvault-Secret "AlarmManagement-CosmosDb-Database-Name" "myplant"

# Add-Keyvault-Secret "AlarmManagement-CosmosDb-Sensors-Collection-Name" "sensors"

# Add-Keyvault-Secret "AlarmManagement-CosmosDb-Alarms-Collection-Name" "alarms"

# Add-AppServicePlan "myplant-eventhub-processor-v2-appplan"

# $ehFuncAppSg = Add-StorageAccount "myplant-eh-func-sg" "Standard_LRS" "StorageV2"

# Add-FunctionApp "myplant-eventhub-processor-funcapp" "myplant-eventhub-processor-v2-appplan" $ehFuncAppSg

# $ehIdentity = Enable-FunctionApp-Identity "myplant-eventhub-processor-funcapp"

# Add-Keyvault-Get-List-Policies $ehIdentity

# $eventhubProcessorFunctionSg = Add-StorageAccount "myplant-eh-function-v2-sg" "Standard_LRS" "StorageV2"

# $eventhubProcessorFunctionSgConn = Get-StorageConnectionString $eventhubProcessorFunctionSg

Add-AppInsight-For-Web "myplant-eventhub-processor-funcapp"

$insightKey = Get-AppInsight-InstrumentKey "myplant-eventhub-processor-funcapp"

# Add-Function-Appsetting "myplant-eventhub-processor-funcapp" "FunctionStorage" $eventhubProcessorFunctionSgConn

# Add-Function-Appsetting "myplant-eventhub-processor-funcapp" "KeyvaultName" "myplant-dev-v2-kv"

Add-Function-Appsetting "myplant-eventhub-processor-funcapp" "APPINSIGHTS_INSTRUMENTATIONKEY" $insightKey





