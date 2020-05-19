$DomainsToTest = @("remote.clientname.com", "clientswebsite.com")
New-item "C:\ProgramData\DNSTestLog" -ItemType Directory -erroraction SilentlyContinue -Force | out-null
 
$DNSHealth = foreach ($DomainToTest in $DomainsToTest) {
 
    Clear-DnsClientCache
 
    $PreviousDNS = get-content "C:\ProgramData\DNSTestLog\$($DomainToTest).txt" -ErrorAction SilentlyContinue
    if (!$PreviousDNS) { 
        write-host "No previous file found. Creating file. Compare will fail."
        "" | Out-File "C:\ProgramData\DNSTestLog\$($DomainToTest).txt"
    }
    $DNSResults = (Resolve-dnsname -name $DomainToTest -Type A -NoHostsFile).IP4Address
    $DNSResults | Out-File "C:\ProgramData\DNSTestLog\$($DomainToTest).txt"
    if ($PreviousDNS -ne $DNSResults) {
        "$DomainToTest does not equal the previous result."
    }
 
}
 
if (!$DNSHealth) {
    $DNSHealth = "Healthy"
}