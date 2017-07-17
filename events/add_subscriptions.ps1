# Add all subscriptions based on subscription files ending in _sub.xml
Get-ChildItem *\*_sub.xml | Foreach { Write-Host "Adding:"$_.fullname; wecutil cs $_.fullname }
