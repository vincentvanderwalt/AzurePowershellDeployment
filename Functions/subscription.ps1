function Select-Subscription {
    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                    Subscription Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host
    Write-Host "Getting available subscriptions" -ForegroundColor Green
    $subscriptions = Get-AzureRmSubscription
    $idx = -1
    Do {

        Write-Host
        for ($i = 0; $i -lt $subscriptions.count; $i++) {
            Write-Host -ForegroundColor Cyan "  $($i+1)." $subscriptions[$i].Name
        }

        Write-Host
        $idx = (Read-Host "Please enter a selection") -as [int]

    } While ((-not $idx) -or (0 -gt $idx) -or ($subscriptions.Count -lt $idx))

    Write-Host ("You're about to use subscription {0}" -f $subscriptions[$idx - 1].Name) -ForegroundColor Green

    $Script:SubscriptionId = $subscriptions[$idx - 1].Id

    Write-Host

    Set-AzureRmContext -SubscriptionId $subscriptions[$idx - 1].Id | Out-Null
}