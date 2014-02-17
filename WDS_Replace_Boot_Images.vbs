'######################################################################################
'#                                                                                    #
'# Script to import the WDS boot images from the MDS DFS share.                       #  
'# Backs up the current boot image to bootBak.wim                                     #
'# Michael Pursell                                                                    #
'#                                                                                    #
'# NOTE: The trailing spaces in the variable strings in the case statements           #
'# are required for the wdsutil command to work.                                      #
'#                                                                                    #
'######################################################################################


Option explicit

'Import / Export vars
Dim ComputerName
Dim WshNetwork
Set WshNetwork = CreateObject("WScript.Network")
ComputerName = WshNetwork.ComputerName
Dim WshShell
Dim ImageName
Dim ReplacementImagePath
Dim Backup
Dim Arch
Dim Server
Dim ImageType
ImageType = "Boot "

'Logging and error control vars
Dim objShell
Dim objExec
Dim objFile
Dim logTxt
Dim objFSO
Set objFSO = CreateObject("Scripting.FileSystemObject")
Dim ExportExitCode
Dim ImportExitCode
Dim objExecResult

'Once we have the local computer name, step through the cases to see which applies. 
Select Case ComputerName

	'
	Case "<Server1>"
		ImageName = """<Image Name>"" "
		ReplacementImagePath = "<path to new boot wim> "
		Backup = "<path to save the old boot wim as backup> "
		Arch = "<x86 / x64> "
		Server = "localhost "
		logTxt = "<path to log file>"
		
	
	
	Case else
		ImageName = """<Image Name>"" "
		ReplacementImagePath = "<path to new boot wim> "
		Backup = "<path to save the old boot wim as backup> "
		Arch = "<x86 / x64> "
		Server = "localhost "
		logTxt = "<path to log file>"
		
		'test block - uncomment this code to echo out the full wdsutil commands for import and export (asuuming you're not on any of the boxes in the case statements).
		'Dim testString 

		'teststring = "wdsutil /Export-Image /Server:" & Server & "/Image:" & ImageName & "/ImageType:" & ImageType & "/Architecture:" & Arch & "/DestinationImage /FilePath:" & Backup & "/Overwrite:Yes"
		'wscript.echo(testString)
		
		'teststring = "wdsutil /Replace-Image /Server:" & Server & "/Image:" & ImageName & "/ImageType" & ImageType & "/Architecture:" & Arch & "/ReplacementImage /ImageFile:" & ReplacementImagePath
		'wscript.echo(testString)

End Select 
	

Set objShell = CreateObject("WScript.Shell")

'Backup -------------------------------------------------------------------------------------------------
Set objExec = objShell.Exec("wdsutil /Export-Image /Server:" & Server & "/Image:" & ImageName & " /ImageType:" & ImageType & " /Architecture:" & Arch & " /DestinationImage /FilePath:" & Backup & " /Overwrite:Yes") 

'Setup some logging and error control

'Make sure we're reading possible error codes
objExecResult = objExec.StdOut.ReadAll()
ExportExitCode = objExec.ExitCode

'Set the log file from the logTxt var in each case
Set objFile = objFSO.CreateTextFile(logTxt, True)
If ExportExitCode <> 0 Then
	objfile.Write(ComputerName & ": WDS EXPORT : " & ExportExitCode & vbcrlf)
	'If the export fails, quit before we import the new image. 
	WScript.quit
Else
	objfile.Write(ComputerName & ": WDS EXPORT : Successful : Backup boot wim @ " & Backup & vbcrlf)
	Wscript.Sleep 10000
End If
	
	
'Import new image -------------------------------------------------------------------------------------
Set objExec = objShell.Exec("wdsutil /Replace-Image /Server:" & Server & "/Image:" & ImageName & "/ImageType" & ImageType & "/Architecture:" & Arch & "/ReplacementImage /ImageFile:" & ReplacementImagePath)

objExecResult = objExec.StdOut.ReadAll()
ImportExitCode = objExec.ExitCode

If ImportExitCode <> 0 Then
	objfile.Write(ComputerName & ": WDS IMPORT : " & ImportExitCode & vbcrlf)
Else
	objfile.Write(ComputerName & ": WDS IMPORT : Successful" & vbcrlf)
End If

