$threshold = "600" #threshold in GB
$DiskSpaceUsed = Get-CimInstance -ClassName Win32_ShadowStorage | Select-Object @{n = "Used (GB)"; e = { [math]::Round([double]$_.UsedSpace / 1GB, 3) } }, @{n = "Max (GB)"; e = { [math]::Round([double]$_.MAxSpace / 1GB, 3) } }, *
$HealthState = foreach ($Disks in $DiskSpaceUsed) {
 
    $Volume = get-volume -UniqueId $DiskSpaceUsed.Volume.DeviceID
    $DiskSize = [math]::Round([double]$volume.Size / 1GB, 3)
    $diskremaining = [math]::Round([double]$volume.SizeRemaining / 1GB, 3)
    if ($Disks.'Used (GB)' -gt $threshold) { "Disk $($Volume.DriveLetter) snapshot size is higher than $Threshold. The disk size is $($diskSize) and it has $($diskremaining) remaining space. The max snapshot size is $($Disks.'Max (GB)')" }
}
 
if (!$HealthState) {
    $HealthState = "Healthy"
}