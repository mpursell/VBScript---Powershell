'Maps a drive to each of the computers in arrComputers and deletes a specified file. 

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

Dim Computer

Dim FilePath
FilePath = "<path to file>"

Dim objFile
Dim results

results = "C:\FileDeleteLog.txt"
Set objFile = objFso.CreateTextFile(results,True)

objFile.Write("Computer," & " Deleted" & vbcrlf)

For Each Computer In arrComputers

	Network.MapNetworkDrive "Z:", "\\"& Computer &"\C$"
	
	'Catch any connection / domain trust error
	If Err.Number <> 0 Then
		objFile.Write(Computer & "," & Err.Description & vbcrlf)
		Err.Clear
	Else
		If objFso.FileExists("Z:" & FilePath) Then
			objFso.DeleteFile("Z:" & FilePath)
			objFile.Write(Computer & ",Deleted" & vbcrlf)
		Else
			objFile.Write(Computer & ",Non-existent file" & vbcrlf)
		End If
	End If
	
	Network.RemoveNetworkDrive "Z:", True
	
Next
	
