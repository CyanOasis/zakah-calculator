# PowerShell script to capture screenshots from WSA emulator
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$outDir = Join-Path $PSScriptRoot "screenshots"

if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

Write-Host "Connecting to WSA emulator..." -ForegroundColor Cyan
& $adb connect 127.0.0.1:58526

$deviceStatus = & $adb devices
if ($deviceStatus -match "device$") {
    Write-Host "Connected! Navigate the app to the screen you want to capture." -ForegroundColor Green
    
    $name = Read-Host "Enter a name for the screenshot (e.g. home, history, wizard)"
    if ([string]::IsNullOrWhiteSpace($name)) { $name = "screenshot" }
    
    $filename = "${name}_$(Get-Date -Format 'yyyyMMdd_HHmmss').png"
    $targetPath = Join-Path $outDir $filename
    
    Write-Host "Capturing screen..."
    & $adb shell screencap -p /sdcard/screen.png
    & $adb pull /sdcard/screen.png $targetPath
    & $adb shell rm /sdcard/screen.png
    
    Write-Host "Screenshot saved to: $targetPath" -ForegroundColor Green
} else {
    Write-Warning "No active emulator found. Make sure WSA is running and the Zakah app is open."
}
