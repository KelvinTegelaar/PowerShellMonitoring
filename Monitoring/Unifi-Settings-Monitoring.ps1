param(
    [string]$URL = 'yourcontroller.controller.tld',
    [string]$port = '8443',
    [string]$User = 'APIUSER',
    [string]$Pass = 'SomeReallyLongPassword',
    [string]$SiteCode = 'default' #you can enter each site here. This way when you assign the monitoring to a client you edit this to match the correct siteID.
)
[string]$controller = "https://$($URL):$($port)"
[string]$credential = "`{`"username`":`"$User`",`"password`":`"$Pass`"`}"
 
 
$errorlist = New-Object -TypeName PSCustomObject
try {
    $null = Invoke-Restmethod -Uri "$controller/api/login" -method post -body $credential -ContentType "application/json; charset=utf-8"  -SessionVariable myWebSession
}
catch {
    Add-Member -InputObject $ErrorList -MemberType NoteProperty -Name APISessionError -Value $_.Exception.Message
}
 
try {
    $NetWorkConf = (Invoke-Restmethod -Uri "$controller/api/s/$SiteCode/list/networkconf" -WebSession $myWebSession).data | Where-Object { $_.Purpose -ne "WAN" }
}
catch {
    Add-Member -InputObject $ErrorList -MemberType NoteProperty -Name APINetworkError -Value $_.Exception.Message
}
 
try {
    $SysInfo = (Invoke-Restmethod -Uri "$controller/api/s/$SiteCode/get/setting" -WebSession $myWebSession).data
}
catch {
    Add-Member -InputObject $ErrorList -MemberType NoteProperty -Name APISysInfoError -Value $_.Exception.Message
}
 
$UnifiOutput = [PSCustomObject]@{
    NetworkNames      = $Networkconf.name
    NetworkCount      = $NetWorkConf.Count
    AdvancedFeatures  = ($Sysinfo.advanced_feature_enabled)
    SpeedTestEnabled  = ($sysinfo | Where-Object { $_.key -eq "Auto_Speedtest" }).enabled
    SpeedTestInterval = ($sysinfo | Where-Object { $_.key -eq "Auto_Speedtest" }).interval
    VoipNetwork       = ($NetWorkConf.name | Where-Object { $_ -like "*VOIP*" }).Count
    GuestNetwork      = ($NetWorkConf.purpose | Where-Object { $_ -like "*guest*" }).Count
    LANNetworks       = ($NetWorkConf.name | Where-Object { $_ -like "*-LAN*" }).Count
    Modules           = [PSCustomObject]@{
        ftp_module           =  $sysinfo.ftp_module
        gre_module           =  $sysinfo.gre_module
        h323_module          =  $sysinfo.h323_module
        pptp_module          =  $sysinfo.pptp_module
        sip_module           =  $sysinfo.sip_module
        tftp_module          =  $sysinfo.tftp_module
        broadcast_ping       =  $sysinfo.broadcast_ping
        receive_redirects    =  $sysinfo.receive_redirects
        send_redirects       =  $sysinfo.send_redirects
        syn_cookies          =  $sysinfo.syn_cookies
        offload_accounting   =  $sysinfo.offload_accounting
        offload_sch          =  $sysinfo.offload_sch
        offload_l2_blocking  =  $sysinfo.offload_l2_blocking
        mdns_enabled         =  $sysinfo.mdns_enabled
        upnp_enabled         =  $sysinfo.upnp_enabled
        upnp_nat_pmp_enabled =  $sysinfo.upnp_nat_pmp_enabled
        upnp_secure_mode     =  $sysinfo.upnp_secure_mode
        mss_clamp            =  $sysinfo.mss_clamp
    }
}
 
if ($UnifiOutput.NetworkCount -lt "3") { write-host "Not enough networks found. Only 3 are present." }
if ($UnifiOutput.SpeedTestEnabled -eq $false) { write-host "Speedtest disabled" }
if ($UnifiOutput.SpeedTestInterval -gt "20") { write-host "Speedtest is not set to run every 20 minutes." }
if ($UnifiOutput.SpeedTestInterval -gt "20") { write-host "Speedtest is not set to run every 20 minutes." }
if ($UnifiOutput.Modules.sip_module -eq $true) { Write-Host "SIP ALG Module is enabled." }