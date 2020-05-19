$MaxBackLog = "100"
$DFSFiles = Get-DfsrState
$DFSBackLogHealth = if ($DFSFiles.count -gt $Maxbacklog) { "There are more than $Maxbacklog in the backlog" } else { "Healthy" }
 
$connections = Get-DfsrConnection | Where-Object {$_.state -ne  'normal'}
$DFSConnectionHealth = if($Connections) { "Fault connections found. Please investigate" } else { "Healthy" }
 
 
$Folders = Get-DfsReplicatedFolder | Where-Object {$_.state -ne  'normal'}
$DFSFolderHealth = if($Folders) { "Faulty folder found. Please investigate" } else { "Healthy" }