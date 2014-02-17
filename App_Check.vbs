'Script to check if machines have a particular application installed
'Run from a DC
'Add list of machines to the array "arrComputers", add the application path to "AppPath"
'Requires Z: to be unassigned before running. 
'Michael Pursell 15/10/2013

Option Explicit
On Error Resume Next

'***********************************************************************************************
'Set these two variables as required.
Dim arrComputers
arrComputers = Array("<Computer1>", "<Computer2>")

Dim AppPath 
AppPath = ("<path to application>")

'***********************************************************************************************

Dim WshShell
Dim objFso
Set WshShell = CreateObject("WScript.Shell")
Set objFso = CreateObject("Scripting.FileSystemObject")

Dim Network
Set Network = CreateObject("Wscript.network")

Dim results
Dim objFile
results = "c:\AppCheck_Results.csv"
Set objFile = objFso.CreateTextFile(results,True)

Dim Computer

objFile.Write("Computer," & " App Installed" & vbcrlf)

For Each Computer In arrComputers

	Network.MapNetworkDrive "Z:", "\\"& Computer &"\C$"
	
	'Catch any connection / domain trust error
	If Err.Number <> 0 Then
		objFile.Write(Computer & "," & Err.Description)
		Err.Clear
	Else
	
		'Path to application goes below
		If objFso.FileExists("Z:" & AppPath) Then
			objFile.Write(Computer & "," &"Yes" & vbcrlf)
		Else
			objFile.Write(Computer & "," & "No" & vbcrlf)	
		End If
	Network.RemoveNetworkDrive "Z:", True
		
	
	
	End If
	
Next
	
