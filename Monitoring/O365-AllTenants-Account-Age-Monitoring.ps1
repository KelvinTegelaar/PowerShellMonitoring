########################## Secure App Model Settings ############################
$ApplicationId = 'YourApplicationID'
$ApplicationSecret = 'YourApplicationSecret' | Convertto-SecureString -AsPlainText -Force
$TenantID = 'YourTenantID'
$RefreshToken = 'YourRefreshToken'
$UPN = "YourUPN"
########################## Script Settings  ############################
$Date = (get-date).AddDays((-90))
$Baseuri = "https://graph.microsoft.com/beta"
write-host "Generating token to log into Azure AD. Grabbing all tenants" -ForegroundColor Green
$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
$aadGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.windows.net/.default' -ServicePrincipal -Tenant $tenantID 
$graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $tenantID 
Connect-AzureAD -AadAccessToken $aadGraphToken.AccessToken -AccountId $upn -MsAccessToken $graphToken.AccessToken -TenantId $tenantID | Out-Null
$tenants = Get-AzureAdContract -All:$true
Disconnect-AzureAD
$OldObjects = foreach ($Tenant in $Tenants) {

    $CustGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes "https://graph.microsoft.com/.default" -ServicePrincipal -Tenant $tenant.CustomerContextId
    write-host "$($Tenant.Displayname): Starting process." -ForegroundColor Green
    $Header = @{
        Authorization = "Bearer $($CustGraphToken.AccessToken)"
    }
    write-host " $($Tenant.Displayname): Grabbing all Users that have not logged in for 90 days." -ForegroundColor Green
    $UserList = (Invoke-RestMethod -Uri "$baseuri/users/?`$select=displayName,UserPrincipalName,signInActivity" -Headers $Header -Method get -ContentType "application/json").value | select-object DisplayName,UserPrincipalName,@{Name='LastLogon';Expression={[datetime]::Parse($_.SignInActivity.lastSignInDateTime)}} | Where-Object { $_.LastLogon -lt $Date }
    $devicesList = (Invoke-RestMethod -Uri "$baseuri/devices" -Headers $Header -Method get -ContentType "application/json").value | select-object Displayname,@{Name='LastLogon';Expression={[datetime]::Parse($_.approximateLastSignInDateTime)}}

   
    [PSCustomObject]@{
        Users = $UserList | where-object {$_.LastLogon -ne $null}
        Devices = $devicesList | Where-Object {$_.LastLogon -lt $Date}
    }
}

if(!$OldObjects) { write-host "No old objects found in any tenant"} else { write-host "Old objects found."; $Oldobjects}