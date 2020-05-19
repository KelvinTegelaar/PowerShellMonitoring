$ENV:UserAge = 30
$age = (get-date).AddDays(-$ENV:UserAge)
$DomainCheck = Get-CimInstance -ClassName Win32_OperatingSystem
if ($DomainCheck.ProductType -ne "2") { write-host "Not a domain controller. Soft exiting." ; exit 0 }
$OldUsers = Get-ADuser-Filter * -properties UserPrincipalName, Enabled, WhenCreated, LastLogonDate | select UserPrincipalName, Enabled, WhenCreated, LastLogonDate | Where-Object { $_.LastLogonDate -lt $age }


if (!$OldUsers) {
    write-host "Healthy"
}
else {
    write-host "Not Healthy - Users found that havent logged in for $ENV:UserAge days"
    write-host @($OldUsers)
} 