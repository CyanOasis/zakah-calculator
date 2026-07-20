$logPath = "C:\Users\Shadman\Documents\Al Raj Zakah\wsa_trace.log"
"--- WSA Launch Trace Started at $(Get-Date) ---" | Out-File -FilePath $logPath -Encoding utf8
"Time Zone: $(Get-TimeZone)" | Out-File -FilePath $logPath -Append -Encoding utf8
"Virtualization Features Enabled Check:" | Out-File -FilePath $logPath -Append -Encoding utf8
Get-CimInstance -ClassName Win32_OptionalFeature | Where-Object { ($_.Name -like "*Virtual*" -or $_.Name -like "*Hyper-V*") -and $_.InstallState -eq 1 } | Select-Object Name, InstallState | Out-String | Out-File -FilePath $logPath -Append -Encoding utf8

$lastChecked = Get-Date
"[`($lastChecked`)] Monitoring Event Logs in real-time for WSA errors..." | Out-File -FilePath $logPath -Append -Encoding utf8

# Monitor for 5 minutes (300 iterations of 1-second sleeps)
for ($i = 0; $i -lt 300; $i++) {
    Start-Sleep -Seconds 1
    $now = Get-Date
    
    # Query Application Errors since last check
    $appEvents = Get-WinEvent -FilterHashtable @{LogName='Application'; Level=2; StartTime=$lastChecked} -ErrorAction SilentlyContinue
    foreach ($ev in $appEvents) {
        if ($ev.Message -like "*Wsa*" -or $ev.Message -like "*Android*" -or $ev.Message -like "*vmwp*" -or $ev.ProviderName -eq "Application Error" -or $ev.Message -like "*Appx*") {
            "[`($now`)] [APP ERROR] [Source: $($ev.ProviderName)]:`n$($ev.Message)`n" | Out-File -FilePath $logPath -Append -Encoding utf8
        }
    }
    
    # Query System Errors since last check
    $sysEvents = Get-WinEvent -FilterHashtable @{LogName='System'; Level=2; StartTime=$lastChecked} -ErrorAction SilentlyContinue
    foreach ($ev in $sysEvents) {
        if ($ev.Message -like "*Wsa*" -or $ev.Message -like "*Hyper-V*" -or $ev.Message -like "*Virtual*" -or $ev.Message -like "*VHD*") {
            "[`($now`)] [SYS ERROR] [Source: $($ev.ProviderName)]:`n$($ev.Message)`n" | Out-File -FilePath $logPath -Append -Encoding utf8
        }
    }
    
    $lastChecked = $now
}

"--- WSA Launch Trace Stopped at $(Get-Date) ---" | Out-File -FilePath $logPath -Append -Encoding utf8
