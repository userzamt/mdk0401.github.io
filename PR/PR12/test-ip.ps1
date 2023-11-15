$mask = "10.207.106."
$file = "address.csv"

Clear-Content -Path $file
Add-Content -Path $file -Value "host,ip"

for($i=1; $i -lt 255; $i++) {
    $ip = $mask + $i
     

    if(Test-Connection $ip -Count 1 -Quiet) {
        $name = Resolve-DnsName -Name $ip -Type PTR -ErrorAction SilentlyContinue 



        if ($name) {
            Write-Host $name.NameHost $ip 

            $str = $name.NameHost + "," + $ip
            Add-Content -Path $file -Value $str
        }

        $name = $null
    } else {
        Write-Host "`t $ip"
    }

}