# the updumper, FINAL version

add to Windows Explorer context menu via regedit:

key: "Computer\HKEY_CLASSES_ROOT\SystemFileAssociations\image\shell\UpDump\command" 

value: "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -File "C:\Tools\scripts\UpDumper.ps1" "%L"

example:

![image](https://user-images.githubusercontent.com/16505004/204710885-3baad1b0-1a5f-45e5-a9a6-71694ac546bc.png)
