$Procs = Get-Process | Where-Object { $_.Path -ne $null }
$PSExecmon = foreach ($Proc in $procs) {
    $Sig = Get-AuthenticodeSignature $proc.path
    if ($Sig.SignerCertificate.Thumbprint -eq "3BDA323E552DB1FDE5F4FBEE75D6D5B2B187EEDC") { $proc }
}
if (!$PSExecmon) {
    $PSExecHealth = "Healthy - no PSExec service found."
}
else {
    $PSExecHealth = "Unhealthy - PSExec service found"
}