function Select-Subscription {
    Param(
        [String]$AzureSubscriptionId
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                    Subscription Selection"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($AzureSubscriptionId)) {
        $subscriptions = (az account list | ConvertFrom-Json)
        $subscriptionName = ''        
        $idx = -1
        if ($subscriptions.Length -eq 1) {
            $subscriptionName = $subscriptions.name
            $AzureSubscriptionId = $subscriptions.id
        }
        else {
            Write-Host "Getting available subscriptions" -ForegroundColor Green
            Do {
            
                Write-Host
                for ($i = 0; $i -lt $subscriptions.count; $i++) {
                    Write-Host -ForegroundColor Cyan "  $($i+1)." $subscriptions[$i].name
                }

                Write-Host
                $idx = (Read-Host "Please enter a selection") -as [int]

            } While ((-not $idx) -or (0 -gt $idx) -or ($subscriptions.Count -lt $idx))

            $subscriptionName = $subscriptions[$idx - 1].name
            $AzureSubscriptionId = $subscriptions[$idx - 1].id
        }
        Write-Host ("You're about to use subscription {0}" -f $subscriptionName) -ForegroundColor Green
    }
    else { 
        Write-Host ("You're about to use subscription {0}" -f $AzureSubscriptionId) -ForegroundColor Green
    }

    az account set --subscription $AzureSubscriptionId
    Write-Host

    return $AzureSubscriptionId
}