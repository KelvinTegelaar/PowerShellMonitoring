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
    Add-VPNconnection @Settings -verbose
}
else {
    Set-VpnConnection @settings -Verbose
}