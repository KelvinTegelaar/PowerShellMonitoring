$AllowedHosts = "google.com", "YourSuperDuperTurboRMM.com", '1.2.3.4'
$isolation = $false


write-host "Checking all IPs for hosts"
$ConvertedHosts = foreach ($Remotehost in $AllowedHosts) {
    $IsIp = ($RemoteHost -as [ipaddress]) -as [bool]
    if ($IsIp) {
        $ipList = $Remotehost
    }
    else {
        $IPList = (Resolve-DnsName $Remotehost).ip4address
    }
    Foreach ($IP in $IPList) {
        [PSCustomObject]@{
            Hostname = $Remotehost
            IP       = $IP
        }
    }
}


if ($isolation) {
    write-host "Checking if Windows firewall is enabled" -ForegroundColor Green
    $WindowsFirewall = Get-NetFirewallProfile | Where-Object { $_.Enabled -ne $false }
    if (!$WindowsFirewall) { 
        write-host "Windows firewall is enabled. Moving onto next task" -ForegroundColor Green
    }
    else {
        Write-Host "Windows Firewall is not enabled. Enabling for extra isolation" -ForegroundColor Yellow
        $WindowsFirewall | Set-NetFirewallProfile -Enabled:True
    }
    write-host "Preparing Windows Firewall isolation rule" -ForegroundColor Green

    $ExistingRule = Get-NetFirewallRule -DisplayName "ISOLATION: Allowed Hosts" -ErrorAction SilentlyContinue
    if ($ExistingRule) {
        write-host "Setting existing Windows Firewall isolation rule" -ForegroundColor Green
        Get-NetFirewallRule -Direction Outbound | Set-NetFirewallRule -Enabled:False
        set-NetFirewallRule -Direction Outbound -Enabled:True -Action Allow -RemoteAddress $ConvertedHosts.IP -DisplayName "ISOLATION: Allowed Hosts"
        get-netfirewallprofile | Set-NetFirewallProfile -DefaultOutboundAction Block
    }
    else {
        write-host "Creating Firewall isolation rule" -ForegroundColor Green
        Get-NetFirewallRule -Direction Outbound | Set-NetFirewallRule -Enabled:False
        New-NetFirewallRule -Direction Outbound -Enabled:True -Action Allow -RemoteAddress $ConvertedHosts.IP -DisplayName "ISOLATION: Allowed Hosts"
        get-netfirewallprofile | Set-NetFirewallProfile -DefaultOutboundAction Block
    }
    write-host "Adding list of hostnames to host file" -ForegroundColor Green
    foreach ($HostEntry in $ConvertedHosts) {
        Add-Content -Path "$($ENV:windir)/system32/drivers/etc/hosts" -Value "`n$($HostEntry.IP)`t`t$($HostEntry.Hostname)"
        start-sleep -Milliseconds 200
    }
    write-host 'Setting DNS to a static server that does not exist' -ForegroundColor Green
    Get-dnsclientserveraddress | Set-DnsClientServerAddress -ServerAddresses 127.0.0.127
    write-host "Clearing DNS cache" -ForegroundColor Green
    Clear-DnsClientCache
    write-host "Stopping 'client' and 'server' service. and setting to disabled" -ForegroundColor Green

    stop-service -name 'Workstation' -Force
    get-service -name 'Workstation' | Set-Service -StartupType Disabled
    stop-service -name 'Server' -Force 
    get-service -name 'server' | Set-Service -StartupType Disabled

    write-host 'Isolation performed. To undo these actions, please run the script with $Isolation set to false' -ForegroundColor Green
}
else {
    write-host "Undoing isolation process." -ForegroundColor Green
    write-host "Setting existing Windows Firewall isolation rule to allow traffic" -ForegroundColor Green
    Get-NetFirewallRule -Direction Outbound | Set-NetFirewallRule -Enabled:True
    Remove-NetFirewallRule -DisplayName "ISOLATION: Allowed Hosts" -ErrorAction SilentlyContinue
    get-netfirewallprofile | Set-NetFirewallProfile -DefaultOutboundAction Allow

    write-host "Removing list of hostnames from host file" -ForegroundColor Green
    foreach ($HostEntry in $ConvertedHosts) {
        $HostFile = Get-Content "$($ENV:windir)/system32/drivers/etc/hosts"
        $NewHostFile = $HostFile -replace "`n$($HostEntry.IP)`t`t$($HostEntry.Hostname)", ''
        Set-Content -Path "$($ENV:windir)/system32/drivers/etc/hosts" -Value $NewHostFile
        start-sleep -Milliseconds 200
    }
    write-host "Clearing DNS cache" -ForegroundColor Green
    Clear-DnsClientCache
    write-host "Setting DNS back to DHCP" -ForegroundColor Green
    Get-dnsclientserveraddress | Set-DnsClientServerAddress -ResetServerAddresses
    write-host "Starting 'Workstation' and 'server' service. and setting to disabled" -ForegroundColor Green
    get-service -name 'Workstation' | Set-Service -StartupType Automatic
    start-service 'Workstation'
    get-service -name 'server' | Set-Service -StartupType Automatic
    start-service 'Server'
    write-host 'Undo Isolation performed. To re-isolate, run the script with the $Isolation parameter set to true.' -ForegroundColor Green
}
