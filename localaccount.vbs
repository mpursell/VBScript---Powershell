'Script to collect local account names from WMI and check them against a known good list.
'Logs any rogue accounts to a csv file in Windows\Temp
'Accepts a /path: param at the command line to specify a local or network... 
'...folder to write the csv file to. 
'M Pursell 2019.

Option Explicit

Dim strComputerName 
Dim outFile 
Dim logFile
Dim objFile 
Dim dictKnownGood 
Dim logPath
Dim colArgs

Set colArgs = Wscript.Arguments.Named

Function getLocalAccounts (strComputerName, dictKnownGood, outFile)

    Dim strComputer
    Dim colItems
    Dim objWMIService
    Dim objItem
    Dim strAccountName

    'Query WMI for the local accounts
    strComputer = "." 
    
    Set objWMIService = GetObject("winmgmts:" _ 
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2") 

    Set colItems = objWMIService.ExecQuery _ 
        ("Select * from Win32_UserAccount Where LocalAccount = True") 
    For Each objItem in colItems 

        'compare the items collected from WMI with the keys in the known good accounts dict,
        'where the key is the account name.
        strAccountName = objItem.Name
        if dictKnownGood.Exists(strAccountName) = True Then 
            'if the item EXISTS in the known good dict, then we don't want to do anything...
        else
            'if it doesn't exist, log it after doing a double check that the account 
            'is a local account. 
            if objItem.LocalAccount = True Then
                
                objFile.Write ""& objItem.Name &"" & "," & strComputerName & "" &  vbCrLf
            
            End If
        End If    
    
    Next

    'close the text file
    objFile.Close
End Function


Function setupEnv()

    Dim wshShell
    Dim objFSO
    Dim strLogPath

    'Get the computer name
    Set wshShell = CreateObject( "WScript.Shell" )
    strComputerName = wshShell.ExpandEnvironmentStrings( "%COMPUTERNAME%" )

    'Set up the dictonary to hold the known good list of accounts
    Set dictKnownGood = CreateObject("Scripting.Dictionary") 

    dictKnownGood.Add "capita_manager", "" & strComputerName & ""
    dictKnownGood.Add "CMD_UNUSED_ACCOUNT_1", "" & strComputerName & ""
    dictKnownGood.Add "DefaultAccount", "" & strComputerName & ""
    dictKnownGood.Add "WDAGUtilityAccount", "" & strComputerName & ""

    'check if we have a /path: param supplied at the command line
    'if we do, use it for the path.  
    if colArgs.Exists("path") Then
        strLogPath = colArgs.Item("path") & "\" & strComputerName & ".csv"
    else
        'otherwise default to a local path in Temp
        strLogPath = "c:\Windows\Temp\" & strComputerName & ".csv"
    End If

    'Set up the file object for output... 
    Set objFSO=CreateObject("Scripting.FileSystemObject")
    outFile = strLogPath
    Set objFile = objFSO.CreateTextFile(outFile,True)

    '...and write the headers for the csv
    objFile.Write "LocalAccountName,ComputerName" & vbCrLf

End Function


call setupEnv()
call getLocalAccounts(strComputerName, dictKnownGood, outFile)



