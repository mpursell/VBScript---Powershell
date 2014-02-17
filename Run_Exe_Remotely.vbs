'Maps a drive to C$ on the computers in arrComputers and then runs an executable on each. 
'Michael Pursell

Option Explicit
On Error Resume Next

'***********************************************************************************************
'Set as required.
Dim arrComputers
arrComputers = Array("<Computer1>","<Computer2>")

'***********************************************************************************************


Dim objFso
Set objFso = CreateObject("Scripting.FileSystemObject")

Dim Network
Set Network = CreateObject("Wscript.network")

Dim Shell
set Shell = CreateObject("Wscript.shell")

Dim Computer

Dim results
Dim objFile
results = "c:\ApplicationInstall_Results.txt"
Set objFile = objFso.CreateTextFile(results,True)


For Each Computer In arrComputers

	Network.MapNetworkDrive "Z:", "\\"& Computer &"\C$"
	
	'Catch any connection / domain trust error
	If Err.Number <> 0 Then
		objFile.Write(Computer & "," & Err.Description & vbcrlf)
		Err.Clear
	Else
		shell.run "<path to executable>"
		WScript.Sleep 5000
	End If
	
	Network.RemoveNetworkDrive "Z:", True
	
Next
	
