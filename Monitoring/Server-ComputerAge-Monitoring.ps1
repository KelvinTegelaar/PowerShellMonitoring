$ENV:ComputerAge = 90
$age = (get-date).AddDays(-$ENV:ComputerAge)
$DomainCheck = Get-CimInstance -ClassName Win32_OperatingSystem
if ($DomainCheck.ProductType -ne "2") { write-host "Not a domain controller. Soft exiting." ; exit 0 }
$OldComputers = Get-ADComputer -Filter * -properties DNSHostName,Enabled,WhenCreated,LastLogonDate | select DNSHostName,Enabled,WhenCreated,LastLogonDate | Where-Object {$_.LastLogonDate -lt $age}


if (!$OldComputers) {
    write-host "Healthy - No computers older than $ENV:ComputerAge found."
}
else {
    write-host"Not Healthy - Computer accounts found older than $ENV:ComputerAge  days"
    write-host @($OldComputers)
}