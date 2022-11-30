# the updumper, FINAL version

add to Windows Explorer context menu via regedit:

key: "Computer\HKEY_CLASSES_ROOT\SystemFileAssociations\image\shell\UpDump\command" 

value: "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -File "C:\Tools\scripts\UpDumper.ps1" "%L"
