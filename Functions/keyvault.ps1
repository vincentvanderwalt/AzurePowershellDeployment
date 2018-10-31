$Script:KeyvaultName

function Add-Keyvault {
    Param(
        [String]$inputKeyvaultName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     Keyvault Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($inputKeyvaultName)) {
        Do {
            $keyvaultName = Read-Host "Please provide a keyvault name"
        } While ([string]::IsNullOrEmpty($keyvaultName))
    }
    else {
        $keyvaultName = $inputKeyvaultName
    }

    if (![string]::IsNullOrEmpty($Script:ResourcePrefix)) {
        $keyvaultName = ("{0}-{1}" -f $Script:ResourcePrefix,$keyvaultName) 
    }

    $Script:KeyvaultName = $keyvaultName

    $keyvaultDetail = (az keyvault list --resource-group dev-vinny-test | ConvertFrom-Json) | where {$_.name -eq $keyvaultName}

    if ([string]::IsNullOrEmpty($keyvaultDetail)) {
        Write-Host -ForegroundColor Green ("Creating Keyvault {0}" -f $keyvaultName)
        az keyvault create --name $keyvaultName --resource-group $Script:Resourcegroup --location $Script:AzureRegion
    } else {
        Write-Host -ForegroundColor Green ("Keyvault {0} already exists" -f $Script:KeyvaultName)
    }
}