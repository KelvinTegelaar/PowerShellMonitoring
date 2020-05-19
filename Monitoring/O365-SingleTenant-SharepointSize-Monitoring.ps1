$ApplicationId = 'YOURAPPLICATIONID'
$ApplicationSecret = 'YOURAPPLICATIONSECRET' | Convertto-SecureString -AsPlainText -Force
$TenantID = 'YOURTENANTID'
$RefreshToken = 'YOURUNBELIEVEBALLYLONGREFRESHTOKEN'
$upn = 'UPN-Used-To-Generate-Tokens'
$TenantToMonitor = "Blabla.onmicrosoft.com"
##############################
 
$LimitsReached = 
 
    write-host "Generating token for $($TenantToMonitor)" -ForegroundColor Green
    $graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $TenantToMonitor
    $Header = @{
        Authorization = "Bearer $($graphToken.AccessToken)"
    }
    Write-Host   "Grabbing data for $($TenantToMonitor)" -ForegroundColor green
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
 
      
 
 
if (!$LimitsReached) {
    Write-Host   "Healthy" -ForegroundColor green
}
else {
    Write-Host   "Unhealthy" -ForegroundColor Red
    $LimitsReached
}