$Script:KeyvaultName = $null

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
        $keyvaultName = ("{0}-{1}" -f $Script:ResourcePrefix, $keyvaultName) 
    }

    $Script:KeyvaultName = $keyvaultName

    $keyvaultDetail = (az keyvault list --resource-group $Script:Resourcegroup | ConvertFrom-Json) | where {$_.name -eq $keyvaultName}

    if ([string]::IsNullOrEmpty($keyvaultDetail)) {
        Write-Host -ForegroundColor Green ("Creating Keyvault {0}" -f $keyvaultName)
        az keyvault create --name $keyvaultName --resource-group $Script:Resourcegroup --location $Script:AzureRegion
    }
    else {
        Write-Host -ForegroundColor Green ("Keyvault {0} already exists" -f $Script:KeyvaultName)
    }
}

function Add-Keyvault-Secret {
    Param(        
        [String]$inputSecretName,
        [String]$inputSecretValue
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     Keyvault Secret Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($Script:KeyvaultName)) {
        Do {
            $keyvaultName = Read-Host "Please provide a keyvault name"
        } While ([string]::IsNullOrEmpty($keyvaultName))

        if (![string]::IsNullOrEmpty($Script:ResourcePrefix)) {
            $keyvaultName = ("{0}-{1}" -f $Script:ResourcePrefix, $keyvaultName) 
        }

        $Script:KeyvaultName = $keyvaultName
    }
    else {
        $keyvaultName = $Script:KeyvaultName
    }

    if ([string]::IsNullOrEmpty($inputSecretName)) {
        Do {
            $secretName = Read-Host "Please provide a secret name"
        } While ([string]::IsNullOrEmpty($secretName))
    }
    else {
        $secretName = $inputSecretName
    }

    if ([string]::IsNullOrEmpty($inputSecretValue)) {
        Do {
            $secretValue = Read-Host "Please provide a secret value"
        } While ([string]::IsNullOrEmpty($secretValue))
    }
    else {
        $secretValue = $inputSecretValue
    }

    $secret = az keyvault secret show --name $secretName --vault-name $Script:KeyvaultName

    if ([string]::IsNullOrEmpty($secret)) {
        Write-Host -ForegroundColor Green ("Creating Keyvault Secret {0}" -f $secretName)
        az keyvault secret set --vault-name $Script:KeyvaultName `
            --name $secretName `
            --value $secretValue
    } else {
        Write-Host -ForegroundColor Green ("Keyvault Secret {0} already exists" -f $secretName)
    }
}

function Add-Keyvault-Get-List-Policies {
    Param(
        [String]$inputPrincipalId
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     Keyvault Policy Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($Script:KeyvaultName)) {
        Do {
            $keyvaultName = Read-Host "Please provide a keyvault name"
        } While ([string]::IsNullOrEmpty($keyvaultName))

        if (![string]::IsNullOrEmpty($Script:ResourcePrefix)) {
            $keyvaultName = ("{0}-{1}" -f $Script:ResourcePrefix, $keyvaultName) 
        }

        $Script:KeyvaultName = $keyvaultName
    }
    else {
        $keyvaultName = $Script:KeyvaultName
    }

    if ([string]::IsNullOrEmpty($inputPrincipalId)) {
        Do {
            $principalId = Read-Host "Please provide a principal Id"
        } While ([string]::IsNullOrEmpty($secretName))
    }
    else {
        $principalId = $inputPrincipalId
    }

    az keyvault set-policy -n $Script:KeyvaultName -g $Script:Resourcegroup --secret-permissions get list --object-id $principalId


}