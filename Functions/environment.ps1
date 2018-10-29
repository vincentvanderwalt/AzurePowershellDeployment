function Select-Environment {
    Param(
        [String]$inputEnvironment
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                    Environment Selection"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($inputEnvironment)) {

        $Environments = @("Dev", "Test", "Prod", "Custom")

        $CurrentIndex = -1

        Write-Host -ForegroundColor Green "Environment Picker"

        Do {

            Write-Host
            for ($i = 0; $i -lt $Environments.count; $i++) {
                Write-Host -ForegroundColor Cyan "  $($i+1)." $Environments[$i]
            }

            Write-Host
            $CurrentIndex = (Read-Host "Please select an environment") -as [int]

        } While ((-not $CurrentIndex) -or (0 -gt $CurrentIndex) -or ($Environments.Count -lt $CurrentIndex))

        $EnvironmentName = $null
        if ($CurrentIndex -eq 4) {
            Do {
                $EnvironmentName = Read-Host "Please provide custom environment name"
            } While ([string]::IsNullOrEmpty($EnvironmentName))
        }
        else {
            $EnvironmentName = $Environments[$CurrentIndex - 1]
        }

    }
    else {
        $EnvironmentName = $inputEnvironment
    }

    Write-Host
    Write-Host ("You're about to deploy resources for {0} environment" -f $EnvironmentName.ToLowerInvariant()) -ForegroundColor Green

    $Script:ResourcePrefix = ("{0}" -f $EnvironmentName.ToLowerInvariant())

}