$days = (Get-Date).AddDays(14)
$TxtBindings = (& netsh http show sslcert) | select-object -skip 3 | out-string
$nl = [System.Environment]::NewLine
$Txtbindings = $TxtBindings -split "$nl$nl"
$BindingsList = foreach ($Binding in $Txtbindings) {
    if ($Binding -ne "") {
        $Binding = $Binding -replace "  ", "" -split ": "
        [pscustomobject]@{
            IPPort          = ($Binding[1] -split "`n")[0] 
            CertificateHash = ($Binding[2] -split "`n" -replace '[^a-zA-Z0-9]', '')[0] 
            AppID           = ($Binding[3] -split "`n")[0]
            CertStore       = ($Binding[4] -split "`n")[0] 
        }
    }
}
 
if ($BindingsList.Count -eq 0) { 
    $CertState = "Healthy - No certificate bindings found."
    exit 0
}
 
$CertState = foreach ($bind in $bindingslist) {
    $CertFile = Get-ChildItem -path "CERT:LocalMachine\MY" | Where-Object -Property ThumbPrint -eq $bind.CertificateHash
    if ($certfile.NotAfter -lt $Days) { "$($certfile.FriendlyName) / $($certfile.thumbprint) will expire on $($certfile.NotAfter)" }    
}