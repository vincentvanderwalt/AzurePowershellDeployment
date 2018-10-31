function Select-Region {
    Param(
        [String]$inputRegion
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                    Region Selection"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host
    
    if ([string]::IsNullOrEmpty($inputRegion)) {
        Write-Host "Getting available regions" -ForegroundColor Green
        $regions = Get-AzureRmLocation

        $idx = -1
        Do {

            Write-Host
            for ($i = 0; $i -lt $regions.count; $i++) {
                Write-Host -ForegroundColor Cyan "  $($i+1)." $regions[$i].DisplayName
            }

            Write-Host
            $idx = (Read-Host "Please enter a selection") -as [int]

        } While ((-not $idx) -or (0 -gt $idx) -or ($regions.Count -lt $idx))

        $Script:AzureRegion = $regions[$idx - 1].Location
    } else {
        $Script:AzureRegion = $inputRegion
    }

    Write-Host ("You're about to use region {0}" -f $Script:AzureRegion) -ForegroundColor Green

    Write-Host
}