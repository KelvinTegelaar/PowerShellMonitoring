$DownloadURL = "https://dl.dell.com/FOLDER05944445M/1/Dell-Command-Update_V104D_WIN_3.1.0_A00.EXE"
$DownloadLocation = "C:\Temp"
 
try {
    $TestDownloadLocation = Test-Path $DownloadLocation
    if (!$TestDownloadLocation) { new-item $DownloadLocation -ItemType Directory -force }
    $TestDownloadLocationZip = Test-Path "$DownloadLocation\DellCommandUpdate.exe"
    if (!$TestDownloadLocationZip) { 
        Invoke-WebRequest -UseBasicParsing -Uri $DownloadURL -OutFile "$($DownloadLocation)\DellCommandUpdate.exe"
        Start-Process -FilePath "$($DownloadLocation)\DellCommandUpdate.exe" -ArgumentList '/s' -Verbose -Wait
        set-service -name 'DellClientManagementService' -StartupType Manual
    }
 
}
catch {
    write-host "The download and installation of DCUCli failed. Error: $($_.Exception.Message)"
    exit 1
}
 
start-process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/scan -report=$DownloadLocation" -Wait
[ xml]$XMLReport = get-content "$DownloadLocation\DCUApplicableUpdates.xml"
#We now remove the item, because we don't need it anymore, and sometimes fails to overwrite
remove-item "$DownloadLocation\DCUApplicableUpdates.xml" -Force
 
$AvailableUpdates = $XMLReport.updates.update
 
$BIOSUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "BIOS" }).name.Count
$ApplicationUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Application" }).name.Count
$DriverUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Driver" }).name.Count
$FirmwareUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Firmware" }).name.Count
$OtherUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Other" }).name.Count
$PatchUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Patch" }).name.Count
$UtilityUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Utility" }).name.Count
$UrgentUpdates = ($XMLReport.updates.update | Where-Object { $_.Urgency -eq "Urgent" }).name.Count