$Sessions = Get-smbsession
$Connections = get-smbconnection
 
 
if ($sessions) {
    foreach ($Session in $Sessions) {
        write-host "a session has been found coming from $($Session.ClientComputerName). The logged on user is $($Session.ClientUserName) with $($Session.NumOpens) opened sessions"
    }
}
else {
    write-host "No sessions found"
}
 
if ($Connections) {
    foreach ($Connection in $Connections) {
        write-host "a Connection has been found on $($Connection.ServerName). The logged on user is $($Connection.Username) with $($Connection.NumOpens) opened sessions"
    }
}
else {
    write-host "No sessions found"
}