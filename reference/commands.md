# Command index

Every command used by the guides, in one copy-pasteable place. See the numbered guide files for explanations.

## Discovery

```powershell
$LD = 'C:\LDPlayer\LDPlayer9'
(Get-Item "$LD\dnplayer.exe").VersionInfo.ProductVersion
& "$LD\ldconsole.exe" list2
Get-ChildItem "$LD" -Force | Select-Object Name, Length
Get-Content "$LD\vms\config\leidians.config" -Raw | ConvertFrom-Json
Get-Content "$LD\vms\leidian0\leidian.vbox" | Select-String 'RAMSize|CPU count'
```

## Apply / re-apply

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\reapply-debloat.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\reapply-debloat.ps1 -Silent
& 'C:\LDPlayer\LDPlayer9\ldconsole.exe' modify --index 0 --cpu 3
```

## Cache + ACL

```powershell
$cache = Join-Path $env:APPDATA 'XuanZhi9\cache'
icacls $cache /remove:d Everyone
icacls $cache /deny 'Everyone:(OI)(CI)W'
(Get-Acl $cache).Access | Where-Object { $_.AccessControlType -eq 'Deny' }
```

## Network

```powershell
Get-Content 'C:\Windows\System32\drivers\etc\hosts' -Raw | Select-String 'LDPlayer-Debloat-Block-'
Get-NetFirewallRule -DisplayName 'LDPlayerBlock-*' | Select-Object DisplayName, Enabled
```

## Task

```powershell
Start-ScheduledTask -TaskName 'LDPlayerDebloatEnforce'
(Get-ScheduledTaskInfo -TaskName 'LDPlayerDebloatEnforce').LastTaskResult
Unregister-ScheduledTask -TaskName 'LDPlayerDebloatEnforce' -Confirm:$false
```

## Verification

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\verify-debloat.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\verify-android.ps1
& 'C:\LDPlayer\LDPlayer9\adb.exe' devices
```

## Android (ADB)

```powershell
$adb = 'C:\LDPlayer\LDPlayer9\adb.exe'
& $adb shell pm list packages -3
& $adb shell pm list packages -d
& $adb shell settings put global private_dns_mode hostname
& $adb shell settings put global private_dns_specifier dns.adguard.com
& $adb shell cmd package set-home-activity ch.deletescape.lawnchair/ch.deletescape.lawnchair.Launcher
```

## Recovery

```powershell
$v = (Get-ChildItem 'C:\LDPlayer\vault' -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
Copy-Item "$v\LDPlayer9\dnrepairer.exe" 'C:\LDPlayer\LDPlayer9\dnrepairer.exe'
Copy-Item "$v\LDPlayer9\LDPlayer_<build>.exe" 'C:\LDPlayer\LDPlayer9\'
```

## Rollback of network blocks

```powershell
# hosts: delete the fenced block between
#   # LDPlayer-Debloat-Block-Begin ... # LDPlayer-Debloat-Block-End
Get-NetFirewallRule -DisplayName 'LDPlayerBlock-*' | Remove-NetFirewallRule
Set-Service LDPlayerENSvr -StartupType Automatic
```
