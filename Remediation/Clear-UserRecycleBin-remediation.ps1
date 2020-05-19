$Days = 14
$Shell = New-Object -ComObject Shell.Application
$Global:Recycler = $Shell.NameSpace(0xa)
foreach ($item in $Recycler.Items()) {
    $DateDel = $Recycler.GetDetailsOf($item, 2) -replace "\u200f|\u200e", "" | get-date
    If ($DateDel -lt (Get-Date).AddDays(-$Days)) { Remove-Item -Path $item.Path -Confirm:$false -Force -Recurse }
} 