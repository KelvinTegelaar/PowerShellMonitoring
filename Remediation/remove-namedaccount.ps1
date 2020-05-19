param(
    $Username,
)
function Remove-NamedAccount ($Username, $type) {
    switch ($type) {
        'Local' {
            $ExistingUser = get-localuser $Username -ErrorAction SilentlyContinue
            if (!$ExistingUser) { 
                write-host "No such user found: $username" -ForegroundColor green
            }
            else {
                write-host "Deleting $username" -ForegroundColor Green
                Remove-LocalUser -Name $Username -Confirm:$false
            }
        }
        'Domain' { 
            $ExistingUser = get-aduser -filter * | Where-Object { $_.SamAccountName -eq $Username } -ErrorAction SilentlyContinue
            if (!$ExistingUser) { 
                write-host "No such user found: $username" -ForegroundColor Green
            }
            else {
                write-host "Deleting $username" -ForegroundColor green
                $ExistingUser | remove-aduser
            }
        }
    }
}
 
$DomainCheck = Get-CimInstance -ClassName Win32_OperatingSystem
switch ($DomainCheck.ProductType) {
    1 { Set-NamedAccount -Username $Username+$NameSeed -Password $Password -type "Local" }
    2 { Set-NamedAccount -Username $Username+$NameSeed -Password $Password -type "Domain" }
    3 { Set-NamedAccount -Username $Username+$NameSeed -Password $Password -type "Local" }
    Default { write-warning -message "Could not get Server Type. Quitting script." }
}