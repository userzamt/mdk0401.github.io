
$index = $( Get-NetAdapter | Where-Object {$_.name -eq 'Ethernet'} | Select-Object -Property ifIndex )
$lhost = $( Get-NetIPAddress | Where-Object {$_.ifIndex -eq $index.ifIndex -and $_.AddressFamily -eq 'IPv4'} )
$addr = $lhost.IPAddress.Split('.')


foreach($num in 1..254) {
    $ip = $addr[0] + "." + $addr[1] + "." + $addr[2] + ".$num"

    if(Test-Connection $ip -Count 1 -Quiet) {
        Write-Host $ip
    }
}
