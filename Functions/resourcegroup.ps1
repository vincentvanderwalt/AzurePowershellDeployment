function Add-Resourcegroup {
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "Please provide a Resourcegroup Name.")]
        [String]$ResourcegroupName
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                   Resourcegroup Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host
    
    $ResourcegroupName = $ResourcegroupName.ToLowerInvariant()

    $resourcegroupExists = az group exists --name $ResourcegroupName

    $resourcegroupExists = [System.Convert]::ToBoolean($resourcegroupExists)

    if (!$resourcegroupExists) {
        Write-Host -ForegroundColor Green ("Creating Resource group {0}" -f $ResourcegroupName)

        $Params = "--name", $ResourcegroupName, "--location", $global:AzureRegion

        (az group create $Params | ConvertFrom-Json) | Out-Null
    }
    else {
        Write-Host -ForegroundColor Green ("Resource group {0} already exists" -f $ResourcegroupName)
    }

    return $ResourcegroupName
}