############ Thresholds #############
$PowerOnTime = 35063 #about 4 years constant runtime.
$PowerCycles = 4000 #4000 times of turning drive on and off
$Temperature = 60 #60 degrees celcius
############ End Thresholds #########
$DownloadURL = "https://cyberdrain.com/wp-content/uploads/2020/02/Smartmontools.zip"
$DownloadLocation = "$($Env:ProgramData)\SmartmonTools"
try {
    $TestDownloadLocation = Test-Path $DownloadLocation
    if (!$TestDownloadLocation) { new-item $DownloadLocation -ItemType Directory -force }
    $TestDownloadLocationZip = Test-Path "$DownloadLocation\Smartmontools.zip"
    if (!$TestDownloadLocationZip) { Invoke-WebRequest -UseBasicParsing -Uri $DownloadURL -OutFile "$($DownloadLocation)\Smartmontools.zip" }
    $TestDownloadLocationExe = Test-Path "$DownloadLocation\smartctl.exe"
    if (!$TestDownloadLocationExe) { Expand-Archive "$($DownloadLocation)\Smartmontools.zip" -DestinationPath $DownloadLocation -Force }
}
catch {
    write-host "The download and extraction of SMARTCTL failed. Error: $($_.Exception.Message)"
    exit 1
}
#update the smartmontools database
start-process -filepath "$DownloadLocation\update-smart-drivedb.exe" -ArgumentList "/S" -Wait
#find all connected HDDs
$HDDs = (& "$DownloadLocation\smartctl.exe" --scan -j | ConvertFrom-Json).devices
$HDDInfo = foreach ($HDD in $HDDs) {
    (& "$DownloadLocation\smartctl.exe" -t short -a -j $HDD.name) | convertfrom-json
}
$DiskHealth = @{}
#Checking SMART status
$SmartFailed = $HDDInfo | Where-Object { $_.Smart_Status.Passed -ne $true }
if ($SmartFailed) { $DiskHealth.add('SmartErrors',"Smart Failed for disks: $($SmartFailed.serial_number)") }
#checking Temp Status
$TempFailed = $HDDInfo | Where-Object { $_.temperature.current -ge $Temperature }
if ($TempFailed) { $DiskHealth.add('TempErrors',"Temperature failed for disks: $($TempFailed.serial_number)") }
#Checking Power Cycle Count status
$PCCFailed = $HDDInfo | Where-Object { $_.Power_Cycle_Count -ge $PowerCycles }
if ($PCCFailed ) { $DiskHealth.add('PCCErrors',"Power Cycle Count Failed for disks: $($PCCFailed.serial_number)") }
#Checking Power on Time Status
$POTFailed = $HDDInfo | Where-Object { $_.Power_on_time.hours -ge $PowerOnTime }
if ($POTFailed) { $DiskHealth.add('POTErrors',"Power on Time for disks failed : $($POTFailed.serial_number)") }
 
if (!$DiskHealth) { $DiskHealth = "Healthy" }