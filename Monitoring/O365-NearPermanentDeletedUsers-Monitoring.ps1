##############################
$Daystomonitor = (Get-Date).AddDays(-28) #This means we will alert when a user has been deleted for 28 days, and is 1 day before permanent deletion.
##############################
$ApplicationId = 'XXXX-XXXX-XXXX-XXX-XXX'
$ApplicationSecret = 'YourApplicationSecret' | Convertto-SecureString -AsPlainText -Force
$TenantID = 'YourTenantID.Onmicrosoft.com'
$RefreshToken = 'VeryLongRefreshToken'
##############################
$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
$aadGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.windows.net/.default' -ServicePrincipal -Tenant $tenantID 
$graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $tenantID 
Connect-MsolService -AdGraphAccessToken $aadGraphToken.AccessToken -MsGraphAccessToken $graphToken.AccessToken
$customers = Get-MsolPartnerContract -All
$DeletedUserlist = foreach ($customer in $customers) {
    write-host "Getting Deleted users for $($Customer.name)" -ForegroundColor Green
    $DeletedUsers = Get-MsolUser -ReturnDeletedUsers -TenantId $($customer.TenantID) | Where-Object {$($User.SoftDeletionTimestamp) -lt $Daystomonitor}
    foreach ($User in $DeletedUsers) { "$($user.UserPrincipalName) has been deleted on $($User.SoftDeletionTimestamp)" }
}
if (!$DeletedUserlist) { $DeletedUserlist= "Healthy" }

