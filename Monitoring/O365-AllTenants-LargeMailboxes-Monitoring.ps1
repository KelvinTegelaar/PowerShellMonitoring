$ApplicationId         = 'xxxx-xxxx-xxx-xxxx-xxxx'
$ApplicationSecret     = 'TheSecretTheSecret' | Convertto-SecureString -AsPlainText -Force
$TenantID              = 'YourTenantID'
$RefreshToken          = 'RefreshToken'
$ExchangeRefreshToken  = 'ExchangeRefreshToken'
$upn                   = 'UPN-Used-To-Generate-Tokens'
$SizeToMonitor         = 60

$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
$aadGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.windows.net/.default' -ServicePrincipal -Tenant $tenantID 
$graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $tenantID 
Connect-MsolService -AdGraphAccessToken $aadGraphToken.AccessToken -MsGraphAccessToken $graphToken.AccessToken
$customers = Get-MsolPartnerContract -All
$LargeMailboxes = @()
foreach ($customer in $customers) {
    write-host "Getting started for $($Customer.name)" -foregroundcolor green
    $token = New-PartnerAccessToken -ApplicationId 'a0c73c16-a7e3-4564-9a95-2bdf47383716'-RefreshToken $ExchangeRefreshToken -Scopes 'https://outlook.office365.com/.default' -Tenant $customer.TenantId
    $tokenValue = ConvertTo-SecureString "Bearer $($token.AccessToken)" -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($upn, $tokenValue)
    $customerId = $customer.DefaultDomainName
    $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.outlook.com/powershell-liveid?DelegatedOrg=$($customerId)&amp;BasicAuthToOAuthConversion=true" -Credential $credential -Authentication Basic -AllowRedirection
    Import-PSSession $session -allowclobber -Disablenamechecking
    $Mailboxes = Get-Mailbox | Get-MailboxStatistics | Select-Object DisplayName, @{name = "TotalItemSize (GB)"; expression = { [math]::Round((($_.TotalItemSize.Value.ToString()).Split("(")[1].Split(" ")[0].Replace(",", "") / 1GB), 2) } }, ItemCount | Sort "TotalItemSize (GB)" -Descending
    foreach ($Mailbox in $Mailboxes) { if ($Mailbox.'TotalItemSize (GB)' -gt  $SizeToMonitor) { $LargeMailboxes += $Mailbox } }
    Remove-PSSession $session
}

if (!$LargeMailboxes) { "No Large mailboxes found" }