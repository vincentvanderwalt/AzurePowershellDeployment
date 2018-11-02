$Script:ResourcePrefix = $null
function Select-Prefix {
    Param(
        [String]$inputPrefix
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                    Prefix Selection"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($inputPrefix)) {

        $Prefixes = @("Dev", "Test", "Prod", "Custom")

        $CurrentIndex = -1

        Write-Host -ForegroundColor Green "Prefix Picker"

        Do {

            Write-Host
            for ($i = 0; $i -lt $Prefixes.count; $i++) {
                Write-Host -ForegroundColor Cyan "  $($i+1)." $Prefixes[$i]
            }

            Write-Host
            $CurrentIndex = (Read-Host "Please select an Prefix") -as [int]

        } While ((-not $CurrentIndex) -or (0 -gt $CurrentIndex) -or ($Prefixes.count -lt $CurrentIndex))

        $PrefixName = $null
        if ($CurrentIndex -eq 4) {
            Do {
                $PrefixName = Read-Host "Please provide custom Prefix name"
            } While ([string]::IsNullOrEmpty($PrefixName))
        }
        else {
            $PrefixName = $Prefixes[$CurrentIndex - 1]
        }

    }
    else {
        $PrefixName = $inputPrefix
    }

    Write-Host
    Write-Host ("You're about to deploy resources with Prefix of {0}" -f $PrefixName.ToLowerInvariant()) -ForegroundColor Green

    $Script:ResourcePrefix = ("{0}" -f $PrefixName.ToLowerInvariant())

}