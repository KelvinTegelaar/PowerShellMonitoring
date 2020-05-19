$APIKEY = "YourShodanAPIKey"
$CurrentIP = (Invoke-WebRequest -uri "http://ifconfig.me/ip" -UseBasicParsing ).Content
$ListIPs = @("1.1.1.1","2.2.2.2",$CurrentIP)
foreach($ip in $ListIPs){
   $Shodan = Invoke-RestMethod -uri "https://api.shodan.io/shodan/host/$($ip)?key=$APIKEY"
}
if(!$Shodan) { $HealthState = "Healthy"} else { $HealthState = "Alert - $($Shodan.ip_str) is found in Shodan."} 