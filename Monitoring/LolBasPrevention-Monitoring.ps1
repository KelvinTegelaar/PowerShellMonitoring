$ScriptBlockLogging = get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
$ScriptBlockEnable = if ($ScriptBlockLogging.EnableScriptBLockLogging -ne 1) { "Error - Script Block Logging is not enabled" } else { "Healthy - Script Block Logging is enabled" }
 
$DangerousCommands = @("iwr", "irm", "curl", "saps", "iex", "Invoke-Expression", "Invoke-RestMethod", "Invoke-WebRequest", "Invoke-RestMethod")
$Aliasses = get-alias | Where-Object { $_.name -in $DangerousCommands -and $_.ResolvedCommandName -ne "Write-Host" } 
if (!$Aliasses) {
    $AliasProtection = "Healthy - Dangerous commands are protected."
}
else {
    $AliasProtection = "Unhealthy - Dangerous commands are not protected. Please investigate."
}
$logInfo = @{ 
    ProviderName = "Microsoft-Windows-PowerShell"
    StartTime    = (get-date).AddHours(-2)
}
$PowerShellEvents = Get-WinEvent -FilterHashtable $logInfo | Select-Object TimeCreated, message
$PowerShellLogs = foreach ($Event in $PowerShellEvents) {
 
    foreach ($command in $DangerousCommands) {
        if ($Event.Message -like "*$Command*") { 
            [pscustomobject] @{
                TimeCreated      = $event.TimeCreated
                EventMessage     = $Event.message
                TriggeredCommand = $command
 
            } 
        }
    }
 
}
 
if(!$PowerShellLogs){
    $PowerShellLogs = "Healthy"
}