# android-refresh.ps1 - Re-applies the INSIDE-ANDROID debloat over ADB. Idempotent.
# Requires: the emulator running, and its "ADB debugging" switch ON (Other tab).
$LD_ROOT = $null
foreach ($candidate in @('C:\LDPlayer\LDPlayer9','C:\LDPlayer\LDPlayer12','C:\LDPlayer\LDPlayer5','C:\LDPlayer\LDPlayer4','C:\LDPlayer\LDPlayer9x')) {
  if (Test-Path "$candidate\adb.exe") { $LD_ROOT = $candidate; break }
}
if (-not $LD_ROOT) {
  $hit = Get-ChildItem 'C:\LDPlayer' -Directory -Force -ErrorAction SilentlyContinue | Where-Object { Test-Path (Join-Path $_.FullName 'adb.exe') } | Select-Object -First 1
  if ($hit) { $LD_ROOT = $hit.FullName }
}
$adb = "$LD_ROOT\adb.exe"
$log = 'C:\LDPlayer\android-refresh-log.txt'
function Log($m){ $l = "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss')  $m"; Add-Content $log $l; Write-Host $l }

$out = (& $adb devices | Out-String)
if ($out -notmatch 'emulator-\d+\s+device') { Log 'FAIL: no emulator visible via adb (is ADB debugging ON?)'; exit 3 }
Log "adb: device attached ($LD_ROOT)"

# 1) Private DNS (ad-blocking resolver)
& $adb shell settings put global private_dns_mode hostname  | Out-Null
& $adb shell settings put global private_dns_specifier dns.adguard.com | Out-Null
$dns = (& $adb shell settings get global private_dns_specifier | Out-String).Trim()
Log "private DNS: $dns"

# 2) disable LD's Android packages (pattern-matched, not hardcoded)
$patterns = @('launcher3','ld.appstore','printspooler','dreams.phototable','ld.market','ldmnq')
$all = (& $adb shell pm list packages | Out-String) -replace 'package:','' -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ }
foreach ($p in $all) {
  foreach ($pat in $patterns) {
    if ($p -match [regex]::Escape($pat)) {
      $res = (& $adb shell pm disable-user --user 0 $p 2>&1 | Out-String).Trim()
      Log "disable-user $p -> $res"
    }
  }
}

# 3) Lawnchair back as HOME if installed
$home = (& $adb shell cmd package query-activities -a android.intent.action.MAIN -c android.intent.category.HOME | Out-String)
if ($home -match 'ch\.deletescape\.lawnchair') {
  & $adb shell cmd package set-home-activity ch.deletescape.lawnchair/ch.deletescape.lawnchair.Launcher | Out-Null
  Log 'HOME set: Lawnchair'
} else {
  Log 'Lawnchair not installed - install it first (see guide Step 12)'
}

# 4) report
$disabled = (& $adb shell pm list packages -d | Out-String) -replace "`r",''
Log 'disabled packages:'; $disabled -split "`n" | ForEach-Object { Log "  $_" }
Log '=== android-refresh done ==='
