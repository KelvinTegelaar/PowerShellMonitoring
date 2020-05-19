 ############################################################
 $ApplicationId         = 'xxxx-xxxx-xxx-xxxx-xxxx'
 $ApplicationSecret     = 'TheSecretTheSecrey' | Convertto-SecureString -AsPlainText -Force
 $TenantID              = 'YourTenantID'
 $RefreshToken          = 'RefreshToken'
 $ExchangeRefreshToken  = 'ExchangeRefreshToken'
 $upn                   = 'UPN-Used-To-Generate-Tokens'
 #############################################################
 $credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
 
 $aadGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.windows.net/.default' -ServicePrincipal -Tenant $tenantID 
 $graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $tenantID 
 
 Connect-MsolService -AdGraphAccessToken $aadGraphToken.AccessToken -MsGraphAccessToken $graphToken.AccessToken
 $customers = Get-MsolPartnerContract -All
 foreach ($customer in $customers) {
   $adminaccounts  = (Get-MsolRoleMember -TenantId $customer.tenantid -RoleObjectId (Get-MsolRole -RoleName "Company Administrator").ObjectId).EmailAddress
   $token = New-PartnerAccessToken -ApplicationId 'a0c73c16-a7e3-4564-9a95-2bdf47383716'-RefreshToken $ExchangeRefreshToken -Scopes 'https://outlook.office365.com/.default' -Tenant $customer.TenantId
   $tokenValue = ConvertTo-SecureString "Bearer $($token.AccessToken)" -AsPlainText -Force
   $credential = New-Object System.Management.Automation.PSCredential($upn, $tokenValue)
   $customerId = $customer.DefaultDomainName
   $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.outlook.com/powershell-liveid?DelegatedOrg=$($customerId)&amp;BasicAuthToOAuthConversion=true" -Credential $credential -Authentication Basic -AllowRedirection
   Import-PSSession $session -allowclobber -DisableNameChecking
   $startDate = (Get-Date).AddDays(-1)
   $endDate = (Get-Date)
   $Logs = @()
   Write-Host "Retrieving logs for $($customer.name)" -ForegroundColor Blue
   do {
     $logs += Search-unifiedAuditLog -SessionCommand ReturnLargeSet -SessionId $customer.name  -ResultSize 5000 -StartDate $startDate -EndDate $endDate -Operations UserLoggedIn
     Write-Host "Retrieved $($logs.count) logs" -ForegroundColor Yellow
   }while ($Logs.count % 5000 -eq 0 -and $logs.count -ne 0)
   Write-Host "Finished Retrieving logs" -ForegroundColor Green
   $logs | Select-Object UserIds, Operations, CreationDate | Where-Object {$_.UserIds -in $AdminAccounts}
 }