$FailingThreshold = 6.5
 
$WinSatResults = Get-CimInstance Win32_WinSAT | Select-Object CPUScore, DiskScore, GraphicsScore, MemoryScore, WinSPRLevel
 
$WinSatHealth = foreach ($Result in $WinSatResults) {
    if ($Result.CPUScore -lt $FailingThreshold) { "CPU Score is $($result.CPUScore). This is less than $FailingThreshold" }
    if ($Result.DiskScore -lt $FailingThreshold) { "Disk Score is $($result.Diskscore). This is less than $FailingThreshold" }
    if ($Result.GraphicsScore -lt $FailingThreshold) { "Graphics Score is $($result.GraphicsScore). This is less than $FailingThreshold" }
    if ($Result.MemoryScore -lt $FailingThreshold) { "RAM Score is $($result.MemoryScore). This is less than $FailingThreshold" }
    if ($Result.WinSPRLevel -lt $FailingThreshold) { "Average WinSPR Score is $($result.winsprlevel). This is less than $FailingThreshold" }
}
if (!$WinSatHealth) {
    $AllResults = ($Winsatresults | out-string)
    $WinSatHealth = "Healthy. $AllResults"
}