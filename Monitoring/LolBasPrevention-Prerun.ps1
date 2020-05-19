New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1 -Force
#Set aliasses to something harmless
$DangerousCommands = @("iwr", "irm", "curl", "saps", "iex", "Invoke-Expression", "Invoke-RestMethod", "Invoke-WebRequest", "Invoke-RestMethod")
foreach ($Command in $DangerousCommands) {
    Set-Alias -Name $Command -Value "write-host" -Option AllScope -Force
}