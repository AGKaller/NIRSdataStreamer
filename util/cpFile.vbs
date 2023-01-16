
Option Explicit

Dim objShell
Set objShell = WScript.CreateObject( "WScript.Shell" )
Dim source : source = Wscript.Arguments(0)
Dim file : file =  Wscript.Arguments(2)
Dim target : target = Wscript.Arguments(1) '
Dim logFile : logFile = Wscript.Arguments(3)
'parameters = "/yq" ' "/ds"
'objShell.Run "XCOPY " & parameters & " """ & source & """ """ & target & """", 0
Dim parameters : parameters = "/R:10 /W:10 /COPY:DT /LOG+:" & logFile '  /IPG:500 'ms between packages

Dim cmnd : cmnd = "robocopy " & " """ & source & """ """ & target & """ """ & file & """ " & parameters

'WScript.Echo "Cmd: [" & cmnd & "]"
objShell.Run cmnd, 0, false
