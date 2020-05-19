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
$UnusedLicensesList = foreach ($customer in $customers) {
    write-host "Getting licenses $($customer.name)" -ForegroundColor Green
    $Licenses = Get-MsolAccountSku -TenantId $($customer.TenantId)
    foreach ($License in $Licenses) { 
        if ($License.ActiveUnits -lt $License.consumedUnits) { "$($customer.name) - $($License.AccountSkuId) has licenses available." }

    }
}
if (!$UnusedLicensesList) { $UnusedLicensesList = "Healthy" } 