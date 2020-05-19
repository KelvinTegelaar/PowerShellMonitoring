##############################
$MonitorDate = (get-date).AddDays(-1)
$ApplicationId = 'XXXX-XXXX-XXXX-XXX-XXX'
$ApplicationSecret = 'YourApplicationSecret' | Convertto-SecureString -AsPlainText -Force
$TenantID = 'YourTenantID.Onmicrosoft.com'
$RefreshToken = 'VeryLongRefreshToken'
##############################
$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
write-host "Generating access tokens" -ForegroundColor Green
$graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $tenantID 
write-host "Connecting to MSOLService" -ForegroundColor Green
Connect-MsolService -AdGraphAccessToken $aadGraphToken.AccessToken -MsGraphAccessToken $graphToken.AccessToken
write-host "Grabbing client list" -ForegroundColor Green
$customers = Get-MsolPartnerContract -All
write-host "Connecting to clients" -ForegroundColor Green

foreach ($customer in $customers) {
    write-host "Generating token for $($Customer.name)" -ForegroundColor Green
    $graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $customer.TenantID
    $Header = @{
        Authorization = "Bearer $($graphToken.AccessToken)"
    }
    write-host "Grabbing Teams for $($Customer.name)" -ForegroundColor Green
    $GroupUri = "https://graph.microsoft.com/v1.0/Groups?`$top=999"
    $Groups = (Invoke-RestMethod -Uri $GroupUri -Headers $Header -Method Get -ContentType "application/json").value | Where-Object { $_.resourceProvisioningOptions -eq "Team" }
    $NewGroups = foreach ($group in $Groups | Where-Object { [datetime]$_.CreatedDateTime -gt $MonitorDate }) { 
        "$($Group.displayName) has been created on $($group.createdDateTime)"
    
    }
}
if(!$NewGroups){ $NewGroups = "Healthy. No New groups have been created."} 