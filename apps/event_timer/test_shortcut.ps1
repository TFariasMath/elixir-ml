$app_path = "C:\Users\USER\Documents\Apuntes_Elixir_Libro\elixir-ml\event_timer\_build\prod\rel\event_timer\bin\event_timer.bat"
$working_dir = "C:\Users\USER\Documents\Apuntes_Elixir_Libro\elixir-ml\event_timer\_build\prod\rel\event_timer\bin"
$shortcut_path = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\EventTimer.lnk"

Write-Host "Testing shortcut creation..."
Write-Host "App path exists: $(Test-Path $app_path)"
Write-Host "Shortcut path: $shortcut_path"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcut_path)
$Shortcut.TargetPath = $app_path
$Shortcut.WorkingDirectory = $working_dir
$Shortcut.Description = "Event Timer"
$Shortcut.Save()

if (Test-Path $shortcut_path) {
    Write-Host "SUCCESS: Shortcut created"
    exit 0
} else {
    Write-Host "FAILURE: Shortcut not created"
    exit 1
}
