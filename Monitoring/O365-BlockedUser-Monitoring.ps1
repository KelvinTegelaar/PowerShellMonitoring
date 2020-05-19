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

$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
$aadGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.windows.net/.default' -ServicePrincipal -Tenant $tenantID 
$graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $tenantID 
Connect-MsolService -AdGraphAccessToken $aadGraphToken.AccessToken -MsGraphAccessToken $graphToken.AccessToken
$customers = Get-MsolPartnerContract -All
$BlockedUserlist = foreach ($customer in $customers) {
    write-host "Getting Blocked users for $($Customer.name)" -ForegroundColor Green
    $BlockedUsers = Get-MsolUser -TenantId $($customer.TenantID) | Where-Object {$_.BlockCredential -eq $true}
    foreach($User in $BlockedUsers){ "$($user.UserPrincipalName) is blocked from logon." }
}
if(!$BlockedUserlist) {  $BlockedUserlist = "Healthy" } 