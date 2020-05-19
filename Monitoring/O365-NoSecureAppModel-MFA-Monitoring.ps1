Connect-MsolService
$customers = Get-MsolPartnerContract -All | where-object {$_.DefaultDomainName -eq $TenantToCheck}
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