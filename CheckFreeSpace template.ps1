#Create variable for log date

$LogDate = get-date -f yyyyMMddhhmm

#Define location of text file containing your servers. It might also
#be stored on a local file system for example, D:\ServerStorageReport\DiskReport

$File = Get-Content -Path \\pathoftextfileholdinglistofservers.txt

#the disk $DiskReport variable checks all servers returned by the $File variable (line 37)

$DiskReport = ForEach ($Servernames in ($File)) 

{Get-WmiObject win32_logicaldisk <#-Credential $RunAccount#> `
-ComputerName $Servernames -Filter "Drivetype=3" `
-ErrorAction SilentlyContinue | 

#return only disks with
#free space less  
#than or equal to 0.1 (10%)

Where-Object {   ($_.freespace/$_.size) -le '0.50'}

} 

#create reports

$DiskReport | 

Select-Object @{Label = "Server Name";Expression = {$_.SystemName}},
@{Label = "Drive Letter";Expression = {$_.DeviceID}},
@{Label = "Total Capacity (GB)";Expression = {"{0:N1}" -f( $_.Size / 1gb)}},
@{Label = "Free Space (GB)";Expression = {"{0:N1}" -f( $_.Freespace / 1gb ) }},
@{Label = 'Free Space (%)'; Expression = {"{0:P0}" -f ($_.freespace/$_.size)}} |

#Export report to CSV file (Disk Report)

Export-Csv -path "\\Path of Report" -NoTypeInformation

