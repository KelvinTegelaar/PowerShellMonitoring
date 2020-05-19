$Settings = @{
    name                  = "Client based VPN"
    alluserconnection     = $true
    ServerAddress         = "remote.clientname.com"
    TunnelType            = "SSTP" #Can be: Automatic, Ikev2m L2TP, PPTP,SSTP.
    SplitTunneling        = $True
    UseWinLogonCredential = $true
    #There's a lot more options to set/monitor. Investigate for your own settings.
}
$VPN = Get-VPNconnection -name $($Settings.name) -AllUserConnection -ErrorAction SilentlyContinue
if (!$VPN) {
    $VPNHealth = "Unhealthy - Could not find VPN Connection."   
} 
else {
    $ExpectedVPNSettings = New-Object PSCustomObject -property $Settings
    $Selection = $propsToCompare = $ExpectedVPNSettings.psobject.properties.name
    $CurrentVPNSettings = $VPN | Select-object $Selection
    $CompareVPNSettings = compare-object $CurrentVPNSettings  $ExpectedVPNSettings -Property $Selection
    if (!$CompareVPNSettings) { $VPNHealth = "Healthy" } else { $VPNHealth = "Unhealthy - Settings do not match." }
}