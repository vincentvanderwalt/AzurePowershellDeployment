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

    $keyvaultDetail = Get-AzureRmKeyVault -VaultName $Script:KeyvaultName

    if (([string]::IsNullOrEmpty($keyvaultDetail))) {
        Write-Host -ForegroundColor Green ("Creating Keyvault {0}" -f $keyvaultName)
        New-AzureRmKeyVault -Name $Script:KeyvaultName -Location $Script:AzureRegion -ResourceGroupName $Script:Resourcegroup -EnabledForDeployment -EnabledForDiskEncryption
    }
    else {
        Write-Host -ForegroundColor Green ("Keyvault {0} already exists" -f $Script:KeyvaultName)
    }
}