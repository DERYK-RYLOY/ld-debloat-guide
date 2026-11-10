# verify-android.ps1 - READ-ONLY Android-side audit over ADB. Run while the emulator is up.
# Prints PASS/FAIL per item. Exit code = number of FAILs.
$LD_ROOT = $null
foreach ($candidate in @('C:\LDPlayer\LDPlayer9','C:\LDPlayer\LDPlayer12','C:\LDPlayer\LDPlayer5','C:\LDPlayer\LDPlayer4','C:\LDPlayer\LDPlayer9x')) {
  if (Test-Path "$candidate\adb.exe") { $LD_ROOT = $candidate; break }
}
if (-not $LD_ROOT) {
  $hit = Get-ChildItem 'C:\LDPlayer' -Directory -Force -ErrorAction SilentlyContinue | Where-Object { Test-Path (Join-Path $_.FullName 'adb.exe') } | Select-Object -First 1
  if ($hit) { $LD_ROOT = $hit.FullName }
}
$adb = "$LD_ROOT\adb.exe"
$fails = 0
function Report($l){ Write-Host $l }
function Verify($name, [scriptblock]$test){
  $ok = $false
  try { $ok = [bool](& $test) } catch { $ok = $false }
  if ($ok) { Report "[PASS] $name" } else { Report "[FAIL] $name"; $script:fails++ }
}

$dev = (& $adb devices | Out-String)
if ($dev -notmatch 'emulator-\d+\s+device') { Report 'SKIP: no emulator attached (start it, then re-run)'; exit 0 }
Report "ADB: connected ($LD_ROOT)"

$thirdParty = (& $adb shell pm list packages -3 | Out-String)
$disabled   = (& $adb shell pm list packages -d | Out-String)
$dns        = (& $adb shell settings get global private_dns_specifier | Out-String).Trim()
$mode       = (& $adb shell settings get global private_dns_mode | Out-String).Trim()
$home       = (& $adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME | Out-String).Trim()

Verify 'Lawnchair installed'          { $thirdParty -match 'ch.deletescape.lawnchair' }
Verify 'Aurora Store installed'       { $thirdParty -match 'com.aurora.store' }
Verify 'Magisk installed'             { $thirdParty -match 'com.topjohnwu.magisk' }
Verify 'Private DNS = adguard'        { $dns -eq 'dns.adguard.com' -and $mode -eq 'hostname' }
Verify 'Lawnchair is HOME'            { $home -match 'ch\.deletescape\.lawnchair' }

foreach ($pat in @('launcher3','ld.appstore')) {
  $present = (& $adb shell pm list packages | Out-String) -match [regex]::Escape($pat)
  $dis = $disabled -match [regex]::Escape($pat)
  if ($present) { Verify "LD package ($pat) disabled" { $dis } }
}
$all = (& $adb shell pm list packages | Out-String) -split "`n" | ForEach-Object { $_ -replace 'package:','' } | ForEach-Object { $_.Trim() } | Where-Object { $_ }
$anythingSuspicious = $false
foreach ($p in $all) {
  if ($p -match 'ldmnq|\.ld(-|\.|$)|ldupload|ldperfect') { $anythingSuspicious = $true }
}
Verify 'no obvious LD-promoted packages remain' { -not $anythingSuspicious }

if ($fails -eq 0) { Report 'RESULT: ALL ANDROID CHECKS PASSED' } else { Report "RESULT: $fails problem(s) found" }
exit $fails
