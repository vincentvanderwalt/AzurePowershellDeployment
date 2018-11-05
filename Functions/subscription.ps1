$Script:SubscriptionId = $null
function Select-Subscription {
    Param(
        [String]$inputSubscription
    )

    Write-Host
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "###                    Subscription Creation"
    Write-Host -ForegroundColor DarkMagenta "###"
    Write-Host -ForegroundColor DarkMagenta "################################################################"
    Write-Host

    if ([string]::IsNullOrEmpty($inputSubscription)) {
        $subscriptions = (az account list | ConvertFrom-Json)
        $subscriptionName = ''
        $subscriptionId = 0
        $idx = -1
        if ($subscriptions.Length -eq 1) {
            $subscriptionName = $subscriptions.name
            $subscriptionId = $subscriptions.id
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
            $subscriptionId = $subscriptions[$idx - 1].id

            Write-Host ("You're about to use subscription {0}" -f $subscriptionName) -ForegroundColor Green
        }
    }
    else {       
        $subscriptionId = $inputSubscription
        Write-Host ("You're about to use subscription {0}" -f $subscriptionId) -ForegroundColor Green
    }

    az account set --subscription $subscriptionId
    Write-Host
}