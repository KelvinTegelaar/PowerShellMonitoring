$previousIP = get-content "$($env:ProgramData)/LastIP.txt" -ErrorAction SilentlyContinue | Select-Object -first 1
if (!$previousIP) { Write-Host "No previous IP found. Compare will fail." }
$Currentip = (Invoke-RestMethod -Uri "https://ipinfo.io/ip") -replace "`n", ""
$Currentip | out-file "$($env:ProgramData)/LastIP.txt" -Force

if ($Currentip -eq $previousIP) {
    write-host "Healthy"
}
else {
    write-host "External WAN address is incorrect. Expected $PreviousIP but received $Currentip"
    write-host @{ 
        CurrentIP = $Currentip
        previousIP = $previousIP
    }
    exit 1
}