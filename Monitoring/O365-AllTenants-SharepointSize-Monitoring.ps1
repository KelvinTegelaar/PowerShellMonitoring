$ApplicationId = 'YOURAPPLICATIONID'
$ApplicationSecret = 'YOURAPPLICATIONSECRET' | Convertto-SecureString -AsPlainText -Force
$TenantID = 'YOURTENANTID'
$RefreshToken = 'YOURUNBELIEVEBALLYLONGREFRESHTOKEN'
$upn = 'UPN-Used-To-Generate-Tokens'
##############################
$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
write-host "Generating access tokens" -ForegroundColor Green
$aadGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.windows.net/.default' -ServicePrincipal -Tenant $tenantID
$graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $tenantID
write-host "Connecting to MSOLService" -ForegroundColor Green
Connect-MsolService -AdGraphAccessToken $aadGraphToken.AccessToken -MsGraphAccessToken $graphToken.AccessToken
write-host "Grabbing client list" -ForegroundColor Green
$customers = Get-MsolPartnerContract -All
write-host "Connecting to clients" -ForegroundColor Green
 
$LimitsReached = foreach ($customer in $customers) {
    write-host "Generating token for $($Customer.name)" -ForegroundColor Green
    $graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $customer.TenantID
    $Header = @{
        Authorization = "Bearer $($graphToken.AccessToken)"
    }
    Write-Host   "Grabbing data for $($customer.name)" -ForegroundColor green
    $OneDriveUsageURI = "https://graph.microsoft.com/v1.0/reports/getOneDriveUsageAccountDetail(period='D7')"
    $OneDriveUsageReports = (Invoke-RestMethod -Uri $OneDriveUsageURI -Headers $Header -Method Get -ContentType "application/json") | ConvertFrom-Csv
 
    $SharepointUsageReportsURI = "https://graph.microsoft.com/v1.0/reports/getSharePointSiteUsageDetail(period='D7')"
    $SharepointUsageReports = (Invoke-RestMethod -Uri $SharepointUsageReportsURI -Headers $Header -Method Get -ContentType "application/json") | ConvertFrom-Csv
     
     
    foreach ($SharepointReport in $SharepointUsageReports) {
        if ([int]$SharepointReport.'File count' -ge [int]"90000") {
            $SharepointReport
        }
    }
 
    foreach ($OneDriveReport in $OneDriveUsageReports) {
        if ([int]$OneDriveReport.'File count' -ge [int]"90000") {
        $OneDriveReport
        }
    }
 
      
 
}
 
if (!$LimitsReached) {
    Write-Host   "Healthy" -ForegroundColor green
}
else {
    Write-Host   "Unhealthy" -ForegroundColor Red
    $LimitsReached
}