######### Secrets #########
$ApplicationId = 'ApplicationID'
$ApplicationSecret = 'ApplicationSecret' | ConvertTo-SecureString -Force -AsPlainText
$TenantID = 'TenantID'
$RefreshToken = 'VeryLongRefreshToken'
$ExchangeRefreshToken = 'LongExchangeToken'
$UPN = "UPN-User-To-Generate-IDs"
######### Secrets #########

$AllowedCountries = @('Belgium', 'Netherlands', 'Germany', 'United Kingdom')
$Skiplist = @("bla1.onmicrosoft.com", "bla2.onmicrosoft.com", "bla2.onmicrosoft.com")

$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
$aadGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.windows.net/.default' -ServicePrincipal -Tenant $tenantID 
$graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $tenantID 
Connect-MsolService -AdGraphAccessToken $aadGraphToken.AccessToken -MsGraphAccessToken $graphToken.AccessToken

$customers = Get-MsolPartnerContract -All | Where-Object { $_.DefaultDomainName -notin $SkipList }

$StrangeLocations = foreach ($customer in $customers) {
    Write-Host "Getting logon location details for $($customer.Name)" -ForegroundColor Green
    $token = New-PartnerAccessToken -ApplicationId 'a0c73c16-a7e3-4564-9a95-2bdf47383716'-RefreshToken $ExchangeRefreshToken -Scopes 'https://outlook.office365.com/.default' -Tenant $customer.TenantId
    $tokenValue = ConvertTo-SecureString "Bearer $($token.AccessToken)" -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($upn, $tokenValue)
    $customerId = $customer.DefaultDomainName
    $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.outlook.com/powershell-liveid?DelegatedOrg=$($customerId)&amp;BasicAuthToOAuthConversion=true" -Credential $credential -Authentication Basic -AllowRedirection
    $null = Import-PSSession $session -CommandName Search-UnifiedAuditLog -AllowClobber
 

    $startDate = (Get-Date).AddDays(-1)
    $endDate = (Get-Date)
    Write-Host "Retrieving logs for $($customer.name)" -ForegroundColor Blue
    $logs = do {
        $log = Search-unifiedAuditLog -SessionCommand ReturnLargeSet -SessionId $customer.name -ResultSize 5000 -StartDate $startDate -EndDate $endDate -Operations UserLoggedIn
        Write-Host "Retrieved $($log.count) logs" -ForegroundColor Yellow
        $log
    } while ($Log.count % 5000 -eq 0 -and $log.count -ne 0)
    Write-Host "Finished Retrieving logs" -ForegroundColor Green
 
    $userIds = $logs.userIds | Sort-Object -Unique

    $LocationMonitoring = foreach ($userId in $userIds) {
 
        $searchResult = ($logs | Where-Object { $_.userIds -contains $userId }).auditdata | ConvertFrom-Json -ErrorAction SilentlyContinue
        $ips = $searchResult.clientip | Sort-Object -Unique
        foreach ($ip in $ips) {
            $IsIp = ($ip -as [ipaddress]) -as [bool]
            if ($IsIp) { $ipresult = (Invoke-restmethod -method get -uri "https://ip2c.org/$($ip)") -split ';' }
            [PSCustomObject]@{
                user              = $userId
                IP                = $ip
                Country           = ($ipresult | Select-Object -index 3)
                CountryCode       = ($ipresult | Select-Object -Index 1)
                Company           = $customer.Name
                TenantID          = $customer.tenantID
                DefaultDomainName = $customer.DefaultDomainName
            }
           
        }

    }
    foreach ($Location in $LocationMonitoring) {
        if ($Location.country -notin $AllowedCountries) { $Location }
    }
}
if (!$StrangeLocations) {
    $StrangeLocations = 'Healthy'
}

$StrangeLocations