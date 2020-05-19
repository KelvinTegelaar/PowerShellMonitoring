$AllowedDHCPServer = "192.168.15.1"
 
#Replace the Download URL to where you've uploaded the DHCPTest file yourself. We will only download this file once. 
$DownloadURL = "https://cyberdrain.com/wp-content/uploads/2020/04/dhcptest-0.7-win64.exe"
$DownloadLocation = "$($Env:ProgramData)\DHCPTest"
try {
    $TestDownloadLocation = Test-Path $DownloadLocation
    if (!$TestDownloadLocation) { new-item $DownloadLocation -ItemType Directory -force }
    $TestDownloadLocationZip = Test-Path "$DownloadLocation\DHCPTest.exe"
    if (!$TestDownloadLocationZip) { Invoke-WebRequest -UseBasicParsing -Uri $DownloadURL -OutFile "$($DownloadLocation)\DHCPTest.exe" }
}
catch {
    write-host "The download and extraction of DHCPTest failed. Error: $($_.Exception.Message)"
    exit 1
}
$Tests = 0
$ListedDHCPServers = do {
    & "$DownloadLocation\DHCPTest.exe" --quiet --query --print-only 54 --wait --timeout 3
    $Tests ++
} while ($Tests -lt 2)
 
$DHCPHealth = foreach ($ListedServer in $ListedDHCPServers) {
    if ($ListedServer -ne $AllowedDHCPServer) { "Rogue DHCP Server found. IP of rogue server is $ListedServer" }
}
 
if (!$DHCPHealth) { $DHCPHealth = "Healthy. No Rogue DHCP servers found." }