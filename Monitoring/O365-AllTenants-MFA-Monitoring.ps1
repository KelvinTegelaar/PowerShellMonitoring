$ApplicationId         = 'xxxx-xxxx-xxxx-xxxx-xxx'
$ApplicationSecret     = 'YOURSECRET' | Convertto-SecureString -AsPlainText -Force
$TenantID              = 'xxxxxx-xxxx-xxx-xxxx--xxx'
$RefreshToken          = 'LongResourcetoken'
$ExchangeRefreshToken  = 'LongExchangeToken'
$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
$aadGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.windows.net/.default' -ServicePrincipal -Tenant $tenantID
$graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $tenantID
 
Connect-MsolService -AdGraphAccessToken $aadGraphToken.AccessToken -MsGraphAccessToken $graphToken.AccessToken
$customers = Get-MsolPartnerContract -All
$MFAType = foreach ($customer in $customers) {
    $users = Get-MsolUser -TenantId $customer.tenantid -all
 
    foreach ($user in $users) {
        $primaryMFA = if ($null -ne $user.StrongAuthenticationUserDetails) { ($user.StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq $true }).methodType } else { "MFA Disabled" } 
        $SecondaryMFA = if ($null -ne $user.StrongAuthenticationUserDetails) { ($user.StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq $false }).methodType } else { "No Secondary Option enabled" } 
        [PSCustomObject]@{
            "DisplayName"   = $user.DisplayName
            "user"          = $user.UserPrincipalName
            "Primary MFA"   = $primaryMFA
            "Secondary MFA" = $SecondaryMFA
        }
    }
}
 
$UnSafeMFAUsers = $MFAType | Where-Object { $_.'Primary MFA' -like "*SMS*" -or $_.'Primary MFA' -like "*voice*" -or $_.'Primary MFA' -like "*OTP*" }
 
if (!$UnSafeMFAUsers) {
    $UnSafeMFAUsers = "Healthy"
} 