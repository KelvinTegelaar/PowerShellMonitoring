$GPOFile = "C:\ProgramData\GPO 1.0 User.log"
 
$Check = Test-Path "C:\ProgramData\GPO 1.0 User.log"
if (!$Check) { 
    $Healthstate = "GPO has not deployed. Log file does not exist."
}
else {
    $State = get-content $GPOFile | Select-Object -last 3
    if ($state[0] -ne "POLICY SAVED.") { $Healthstate = "GPO Log found but policy not saved." } else { $Healthstate = "Healthy" }
}