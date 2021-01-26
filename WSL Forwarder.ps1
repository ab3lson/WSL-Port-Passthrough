#Gets WSL IP
$wsl_ip = (wsl hostname -I).trim()
Write-Host "WSL2 IP: ""$wsl_ip"""

#All the ports you want to forward separated by coma
$ports=@(22,80,5000,8000);
$ports_a = $ports -join ",";

If ($args[0] -eq "remove"){
    for ($i = 0; $i -lt $ports.length; $i++)
    {
      $port = $ports[$i];
      Write-Host "Stopping port forward for port $port";
      netsh interface portproxy delete v4tov4 listenport=$port
      Write-Host "Closing port $port";
      netsh advfirewall firewall delete rule `"@Open Port $port`"
    }
}else{
    #Loops over ports array and forwards the ports
    for ($i = 0; $i -lt $ports.length; $i++)
    {
      $port = $ports[$i];
      Write-Host "Forwarding port $port";
      netsh interface portproxy add v4tov4 listenport=$port connectport=$port connectaddress=$wsl_ip
      Write-Host "Opening port $port";
      netsh advfirewall firewall add rule name=`"@Open Port $port`" dir=in action=allow remoteip=LocalSubnet profile=domain,private protocol=TCP localport=$port
    }

    Write-Host 'View if the ports are open with "netsh interface portproxy show all"';
    Write-Host 'View firewall rules in "Windows Defender Firewall with Advanced Security". They will start with @.';
    Write-Host 'Rerun script with arg "remove" to undo all these rules.';
}


