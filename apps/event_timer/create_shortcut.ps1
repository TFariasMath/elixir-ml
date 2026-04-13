$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\EventTimer.lnk")
$Shortcut.TargetPath = "C:\Users\USER\Documents\Apuntes_Elixir_Libro\elixir-ml\event_timer\_build\prod\rel\event_timer\bin\event_timer.bat"
$Shortcut.WorkingDirectory = "C:\Users\USER\Documents\Apuntes_Elixir_Libro\elixir-ml\event_timer\_build\prod\rel\event_timer\bin"
$Shortcut.Description = "Event Timer"
$Shortcut.Save()
Write-Host "Shortcut created"
