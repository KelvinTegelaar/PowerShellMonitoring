$DownloadLocation = "C:\Program Files\Dell\CommandUpdate"
start-process "$($DownloadLocation)\dcu-cli.exe" -ArgumentList "/applyUpdates -autoSuspendBitLocker=enable -reboot=enable" -Wait

#
$DownloadLocation = "C:\Program Files\Dell\CommandUpdate"
start-process "$($DownloadLocation)\dcu-cli.exe" -ArgumentList "/applyUpdates -autoSuspendBitLocker=disable -reboot=disable" -Wait

#
$DownloadLocation = "C:\Program Files\Dell\CommandUpdate"
start-process "$($DownloadLocation)\dcu-cli.exe" -ArgumentList "/applyUpdates -autoSuspendBitLocker=enable -reboot=enable -updateType=bios" -Wait