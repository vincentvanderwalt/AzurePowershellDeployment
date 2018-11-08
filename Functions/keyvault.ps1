function Add-Keyvault {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Keyvault name.")]
        [String]$KeyvaultName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     Keyvault Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host
   

    $keyvaultDetail = (az keyvault list --resource-group $global:Resourcegroup | ConvertFrom-Json) | Where-Object {$_.name -eq $keyvaultName}

    if ([string]::IsNullOrEmpty($keyvaultDetail)) {
        Write-Host -ForegroundColor Green ("Creating Keyvault {0}" -f $KeyvaultName)

        $Params = "-n", $KeyvaultName,
        "-g", $global:Resourcegroup,
        "--location", $global:AzureRegion

        (az keyvault create `
                $Params `
                | ConvertFrom-Json)
    }
    else {
        Write-Host -ForegroundColor Green ("Keyvault {0} already exists" -f $KeyvaultName)
    }

    return $KeyvaultName
}

function Add-Keyvault-Secret {
    Param(        
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Secret name.")]
        [String]$SecretName,
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Secret name.")]
        [String]$SecretValue
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     Keyvault Secret Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($global:KeyvaultName)) {
        Do {
            $global:KeyvaultName = Read-Host "Please provide a keyvault name"
        } While ([string]::IsNullOrEmpty($global:KeyvaultName))
    }

    $Params = "--name", $SecretName, 
    "--vault-name", $global:KeyvaultName

    $SecretDetail = az keyvault secret show $Params

    if ([string]::IsNullOrEmpty($SecretDetail)) {
        Write-Host -ForegroundColor Green ("Creating Keyvault Secret {0}" -f $SecretName)

        $Params += "--value", $SecretValue

        (az keyvault secret set `
                $Params `
                | ConvertFrom-Json) | Out-Null
    }
    else {
        Write-Host -ForegroundColor Green ("Keyvault Secret {0} already exists" -f $SecretName)
    }
}

function Add-Keyvault-Get-List-Policies {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Principal Id to associate with the policy.")]
        [String]$PrincipalId
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                     Keyvault Policy Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($global:KeyvaultName)) {
        Do {
            $global:KeyvaultName = Read-Host "Please provide a keyvault name"
        } While ([string]::IsNullOrEmpty($global:KeyvaultName))
    }

    $Params = "-n", $global:KeyvaultName,
    "-g", $global:Resourcegroup,
    "--secret-permissions", "get", "list",
    "--object-id", $PrincipalId

    (az keyvault set-policy $Params | ConvertFrom-Json) | Out-Null
}