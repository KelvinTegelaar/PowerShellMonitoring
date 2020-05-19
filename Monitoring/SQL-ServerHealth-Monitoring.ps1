import-module SQLPS
$Instances = Get-ChildItem "SQLSERVER:\SQL\$($ENV:COMPUTERNAME)"
foreach ($Instance in $Instances) {
    $databaseList = get-childitem "SQLSERVER:\SQL\$($ENV:COMPUTERNAME)\$($Instance.Displayname)\Databases"
    $SkipDatabases = @("Master","Model","ReportServer","SLDModel.SLDData")
    $Errors =  foreach ($Database in $databaselist | Where-Object {$_.Name -notin $SkipDatabases}) {
        if ($Database.status -ne "normal") {"$($Database.name) has the status: $($Database.status)" }
        if ($Database.RecoveryModel -ne "Simple") {  "$($Database.name) is in logging mode $($Database.RecoveryModel)" }
        if ($database.filegroups.files.MaxSize -ne "-1") { "$($Database.name) has a Max Size set." }
        if ($database.filegroups.files.filename -contains "C:") { "$($Database.name) is located on the C:\ drive." }
    }
}
if (!$errors) { $HealthState = "Healthy" } else { $HealthState = $Errors } 