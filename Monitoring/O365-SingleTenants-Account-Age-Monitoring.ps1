########################## Secure App Model Settings ############################
$ApplicationId = 'YourApplicationID'
$ApplicationSecret = 'YourApplicationSecret' | Convertto-SecureString -AsPlainText -Force
$TenantID = 'YourTenantID'
$RefreshToken = 'YourRefreshToken'
$UPN = "YourUPN"
$CustomerTenant = "Customer.onmicrosoft.com"
########################## Script Settings  ############################
$Date = (get-date).AddDays(-90)
$Baseuri = "https://graph.microsoft.com/beta"
write-host "Generating token to log into Azure AD. Grabbing all tenants" -ForegroundColor Green
$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
$CustGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes "https://graph.microsoft.com/.default" -ServicePrincipal -Tenant $CustomerTenant
write-host "$($Tenant.Displayname): Starting process." -ForegroundColor Green
$Header = @{
    Authorization = "Bearer $($CustGraphToken.AccessToken)"
}
write-host " $($Tenant.Displayname): Grabbing all Users that have not logged in for 90 days." -ForegroundColor Green
$UserList = (Invoke-RestMethod -Uri "$baseuri/users/?`$select=displayName,UserPrincipalName,signInActivity" -Headers $Header -Method get -ContentType "application/json").value | select-object DisplayName, UserPrincipalName, @{Name = 'LastLogon'; Expression = { [datetime]::Parse($_.SignInActivity.lastSignInDateTime) } } | Where-Object { $_.LastLogon -lt $Date }
$devicesList = (Invoke-RestMethod -Uri "$baseuri/devices" -Headers $Header -Method get -ContentType "application/json").value | select-object Displayname, @{Name = 'LastLogon'; Expression = { [datetime]::Parse($_.approximateLastSignInDateTime) } }

   
$OldObjects = [PSCustomObject]@{
    Users   = $UserList | where-object { $_.LastLogon -ne $null }
    Devices = $devicesList | Where-Object { $_.LastLogon -lt $Date }
}

if (!$OldObjects) { write-host "No old objects found in any tenant" } else { write-host "Old objects found."; $Oldobjects }