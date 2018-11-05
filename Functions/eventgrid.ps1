function Add-EventGrid-Webhook {
    Param(
        [String]$inputEventGridName,
        [String]$inputEndpoint

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
}