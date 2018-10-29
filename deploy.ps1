. ".\Functions\login.ps1"
. ".\Functions\subscription.ps1"
. ".\Functions\environment.ps1"
. ".\Functions\region.ps1"
. ".\Functions\resourcegroup.ps1"

$Script:SubscriptionId = $null
$Script:ResourcePrefix = $null
$Script:AzureRegion = $null
$Script:Resourcegroup = $null

Login

Select-Subscription

Select-Environment "Dev"

Select-Region "ukwest"

Add-Resourcegroup "vinny-test"

