#Script will swift through txt file containing hostnames. Will output network information.
#Output will need to be fed into CSV file 
#Eric Burgos
 
begin {}
process {
 get-content \\path of text file containing list of hosts | Where-Object {!($_ -match "#")} | 
ForEach-Object {
  if(Test-Connection -ComputerName $_ -Count 1 -ea 0) {
   try {
    $Networks = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $_ -EA Stop | ? {$_.IPEnabled}
   } catch {
        Write-Warning "Error occurred while querying $computer."
        Continue
   }
   foreach ($Network in $Networks) {
    $IPAddress  = $Network.IpAddress[0]
    $SubnetMask  = $Network.IPSubnet[0]
    $DefaultGateway = $Network.DefaultIPGateway
    $DNSServers  = $Network.DNSServerSearchOrder
    $WINS1 = $Network.WINSPrimaryServer
    $WINS2 = $Network.WINSSecondaryServer   
    $WINS = @($WINS1,$WINS2)         
    $IsDHCPEnabled = $false
    If($network.DHCPEnabled) {
     $IsDHCPEnabled = $true
    }
    $MACAddress  = $Network.MACAddress
    $OutputObj  = New-Object -Type PSObject
    $OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $_.ToUpper()
    $OutputObj | Add-Member -MemberType NoteProperty -Name IPAddress -Value $IPAddress
    $OutputObj | Add-Member -MemberType NoteProperty -Name SubnetMask -Value $SubnetMask
    $OutputObj | Add-Member -MemberType NoteProperty -Name Gateway -Value ($DefaultGateway -join ",")      
    $OutputObj | Add-Member -MemberType NoteProperty -Name IsDHCPEnabled -Value $IsDHCPEnabled
    $OutputObj | Add-Member -MemberType NoteProperty -Name DNSServers -Value ($DNSServers -join ",")     
    $OutputObj | Add-Member -MemberType NoteProperty -Name WINSServers -Value ($WINS -join ",")        
    $OutputObj | Add-Member -MemberType NoteProperty -Name MACAddress -Value $MACAddress
    $OutputObj
   }
  }
 }
}
 
end {}
