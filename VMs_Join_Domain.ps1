#Script to join multiple VMs to the domain
#Script assumes machines are powered off and dropped from the domain 
#Script requires VMWare PowerCli to be installed and that a VMs.txt file exists with a list of VM names, no extra whitespace.
#Mike Pursell 2013


#set domain creds
$credUser = "sa_pursellm@pemsdublin.com"
$credPassword = "Password09"


#wmic command to join domain
$domainJoin = "wmic.exe computersystem where Name=""%COMPUTERNAME%"" call joindomainorworkgroup AccountOU=""Virtual Wks`;OU=All Computers`;OU=Capita`;DC=PEMSDUBLIN`;DC=com"" FJoinOptions=1 Name=""pemsdublin.com"" Password=""$credPassword"" Username = ""$credUser"""



#Start the VMs

get-content "C:\Users\sa_pursellm\Desktop\vmscripts\VMs.txt"|
foreach-object{
	start-vm $_ -Confirm:$false	
}

#Give the VMs a a chance to get back upc
Write-Host "Sleeping for 2 minutes while VMs power up..."
Start-Sleep -s 180

get-content "C:\Users\sa_pursellm\Desktop\vmscripts\VMs.txt"|
foreach-object{
	
	#Add-Computer -ComputerName $_ -LocalCredential $_\Administrator -DomainName pemsdublin.com -Credential PEMSDUBLIN.com\mpursell -Restart
	Invoke-VMScript -VM $_ -ScriptType bat -ScriptText $domainJoin -GuestUser $_\administrator -GuestPassword LOC321XP
	Start-Sleep -s 10
	shutdown-vmguest $_ -Confirm:$false
}

Write-Host "Sleeping for 2 minutes while VMs power down..."
Start-Sleep -s 180

get-content "C:\Users\sa_pursellm\Desktop\vmscripts\VMs.txt"|
foreach-object{
	start-vm $_ -Confirm:$false
}

Write-Host "Domain join Complete - Finished"
